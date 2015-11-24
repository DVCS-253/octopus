# CSC 253 - DVCS Project 
# Repos implementation
# 11/20/2015 

# require_relative 'revlog'
require 'json'

# For Tree structrue
# Tree class and Snapshot class (represents nodes in the tree)


# Snapshot(node) has snapshot_ID, repos_hash with file_title and file_id
# parent(last commit), child (next commit)

class Tree
	# $last_commit = nil
	# $current_branch = "master"

	attr_accessor :snapshots, :current_branch

	def initialize()
		@snapshots = Array.new
		@current_branch = "master"
	end	

	def find_snapshot(snapshot_ID)
		# time we are looking for
		p "old id" + snapshot_ID
		s = Marshal::load(snapshot_ID)
		p "looking for" + s.commit_time.to_s
		for snapshot in @snapshots
			p snapshot.commit_time.to_s
			if snapshot.commit_time.to_s == s.commit_time.to_s
				p "FOUND"
				return snapshot
			end
		end

		raise "Unable to find Snapshot with snapshot_id #{snapshot_ID}"
	end

	def add_snapshot
		snapshot = Snapshot.new()
		snapshot.snapshot_ID = Marshal::dump(snapshot) 
		@snapshots.push(snapshot)
		return snapshot
	end

end

class Snapshot
	attr_accessor :snapshot_ID, :repos_hash, :parent, :child, :root, :commit_time, :branch_name, :branch_HEAD, :branches

	def initialize
		@snapshot_ID = 0
		@repos_hash = {}
		@parent = []
		@child = []
		@root = false
		@commit_time = Time.new
		@branch_name = "master"
		@branch_HEAD = false
		@branches = []
	end

	def add_child(node)
		@child.push(node)
	end

	def add_parent(node)
		@parent.push(node)
	end
end


class Repos

	############################################################################

	# General ideas of Repos
	# Contains snapshots that record history of each commit,
	# So users are able to get whatever history they want with
	# contents of files with Revlog module

	# Dependency:
	# Revlog: is sued to store the contents of the committed files and obatain a file_id

	# data structure for Repos is a tree
	# Every node in the tree represents one snapshot/commit with its snapshot_id
	# Specifically, for each Node, it has
	#  1.a snapshot_ID
	#  2.a hashtable which contains the title of files and a file_ID generated
	# by Revlog module

	############################################################################

	# Initialize the repo directory

	@@repo_dir = File.join(Dir.pwd, ".octopus/repo")
	@@comm_dir = File.join(Dir.pwd, ".octopus/communication")
	@@head_dir = File.join(@@repo_dir, "head")
	@@text_file_dir = File.join(@@comm_dir, "text_file")
	@@store_dir = File.join(@@repo_dir, "store")

	def self.init
		# For testing
		# Dir.mkdir("/Users/haochen/Desktop/test/.octopus")
		# Dir.mkdir("/Users/haochen/Desktop/test/.octopus/repo")

		# Created .octopus/repo on current directory
		# Dir.mkdir(File.join(Dir.pwd, ".octopus"), 0700)
		# Dir.mkdir(File.join(Dir.pwd, ".octopus/repo"), 0700)
		# Dir.mkdir(File.join(Dir.pwd, ".octopus/communication"), 0700)
		p "in repo init"
		
		# Created snapshot_tree
		@@snapshot_tree = Tree.new

		# Marshal dump
		File.open(@@store_dir, 'wb'){|f| f.write(Marshal.dump(@@snapshot_tree))}
		# $last_commit is HEAD
		# $last_commit = Snapshot.new(nil)
		File.open(@@head_dir, 'w'){ |f| f.write ("0")}
	end

	
	# First Read the latest commit(HEAD)
	# if nil, which means this is the first commit
	# So this snapshot will be the root fo the tree
	# Set snapshot ID to 1 and make root = true

	# if not nil, make this commit be the child of 
	# last commit on this branch

	# files_to_be_commits is a list of files ex.["/path/a.rb", "/path/b.rb", "/path/c.rb"]
	# hashtable in each snapshot will be this format:
	#   -------------------------------------------
	#  |"a.rb" => "file_id of a.rb get from Revlog"|
	#  |"b.rb" => "file_id of b.rb get from Revlog"|
	#  |"c.rb" => "file_id of c.rb get from Revlog"|
	#   -------------------------------------------

	def self.make_snapshot(files_to_be_commits)
		p files_to_be_commits.class
		@@snapshot_tree = Marshal.load(File.binread(@@store_dir))
		@@head = File.open(@@head_dir, 'r'){|f| f.read}

		if @@head == "0"
			p "adding the first snapshot"
			snapshot = @@snapshot_tree.add_snapshot
			# Record commit time of this commit
			snapshot.commit_time = Time.now
			snapshot.root = true
			p snapshot.snapshot_ID.class
			File.open(@@head_dir, 'wb'){ |f| f.write ("#{snapshot.snapshot_ID}")}
			# puts Marshal::load(File.binread(@@head_dir))
		else
			p "adding the non first snapshot"
			# latest_branch is the latest commit on this branch
			# which means find last appearance snapshot with current branch name
			# just reverse array and find first appearance 
			r_ids = @@snapshot_tree.snapshots.reverse
			latest_branch = r_ids.find {|x| x.branch_name == @@snapshot_tree.current_branch}

			# add new snapshot
			snapshot = @@snapshot_tree.add_snapshot
			# Record commit time of this commit
			snapshot.commit_time = Time.now
			# Record branch name
			snapshot.branch_name = @@snapshot_tree.current_branch

			latest_branch.add_child(snapshot)
			snapshot.add_parent(latest_branch)
			# Then head becomes this snapshot' ID
			File.open(@@head_dir, 'wb'){ |f| f.write ("#{snapshot.snapshot_ID}")}
		end
		files_to_be_commits.each do |file_path, content|
			# get basename, like "a.rb"
			file_name = File.basename(file_path)
			file_time = File.mtime(file_path)
			# send contents of each file and get file_id from Revlog
			# Save to hash with it's basename
			snapshot.repos_hash["#{file_path}"] = Revlog.add_file([content, file_time])
		end

		p snapshot.branch_name
		p snapshot.repos_hash.to_a.inspect
		p "all snapshots #{@@snapshot_tree.snapshots.count}"

		File.open(@@store_dir, 'wb'){|f| f.write(Marshal.dump(@@snapshot_tree))}
		return snapshot.snapshot_ID
	end

	def self.add_branch(branchname)
		@@head = File.open(@@head_dir, 'r'){|f| f.read}
		h = Marshal::load(File.binread(@@head))
		new_branch = h.dup
		new_branch.snapshot_ID = 0
		new_branch.branch_name = branchname
		new_branch.add_parent = h
		@@snapshots.push(new_branch)
		File.open(@@head_dir, 'wb'){ |f| f.write ("#{snapshot.snapshot_ID}")}
	end

	# returns a specific snapshot

	def self.restore_snapshot(snapshot_ID)

		@@snapshot_tree = Marshal.load(File.binread(@@store_dir))
		snapshot = @@snapshot_tree.find_snapshot(snapshot_ID)
		
		# # put file_id into file_id_lists
		# file_id_lists = Array.new
		# snapshot.repos_hash.each do |file_dir, file_id|
		# 	file_id_lists << file_id
		# end

		return snapshot
	end

	# returns all parents of certain node_id

	def self.history(snapshot_ID)

		@@snapshot_tree = Marshal.load(File.binread(@@store_dir))
		# First find that snapshot
		snapshot = @@snapshot_tree.find_snapshot(snapshot_ID)
		@@list_of_snapshots = Array.new
		history_helper(snapshot)
		# add root snapshot_id
		@@list_of_snapshots << @@snapshot_tree.snapshots[0].snapshot_ID
		# since this method will duplicate count snapshots
		# use .uniq to remove any duplicate
		@@list_of_snapshots = @@list_of_snapshots.uniq

		return @@list_of_snapshots
	end

	# helper to find all histories
	def self.history_helper(snapshot)
		while snapshot.root != true
			# If only one parent, just add it to list
			if snapshot.parent.length == 1
				@@list_of_snapshots << snapshot.parent[0].snapshot_ID
				snapshot = snapshot.parent[0]
			else
				# a snapshot has at most two parents
				# (by merging)
				history_helper(snapshot.parent[0])
				history_helper(snapshot.parent[1])
			end
		end

	end

	# Make 1 child from current HEAD 
	def self.make_branch(branch_name)

		@@snapshot_tree = Marshal.load(File.binread($store_dir))
		@@head = File.open(@@head_dir, 'r'){|f| f.read}
		# Make a Json file in repo named "branches.json"
		json_dir = File.join(@@repo_dir, "branches.json")
		# Record branch_name and HEAD's snapshot_ID
		jhash = {"#{branch_name}" => "#{@@head}"}
		File.open(json_dir, "w") do |f|
			f.write(jhash.to_json)
		end

		# Add snapshot, which is the head of new branch to snapshot_tree
		snapshot_branch = @@snapshot_tree.add_snapshot
		snapshot_branch.branch_name = branch_name
		snapshot_branch.branch_HEAD = true

		# Find current head
		@@head_snapshot = @@snapshot_tree.find_snapshot(@@head)

		@@head_snapshot.add_child(snapshot_branch)
		snapshot_branch.add_parent(@@head_snapshot)
		# Copy repos_hash from current head
		snapshot_branch.repos_hash = @@head_snapshot.repos_hash
		# Means current head has a child with branch's name branch_name
		@@head_snapshot.branches.push(branch_name)

		# transfer current branch to this branch
		@@snapshot_tree.current_branch = branch_name
		@@head = snapshot_branch.snapshot_ID

		# update "head" and "store"
		File.open(@@head_dir, 'w'){ |f| f.write ("#{@@head}")}
		File.open(@@store_dir, 'wb'){|f| f.write(Marshal.dump(@@snapshot_tree))}


	end

	# means delete the whole branch? 
	def self.delete_branch(branch_name)

		@@snapshot_tree = Marshal.load(File.binread(@@store_dir))
		# Delete all snapshots with this branch name
		@@snapshot_tree.snapshots.delete{|x| x.branch_name == branch_name}
		File.open(@@store_dir, 'wb'){|f| f.write(Marshal.dump(@@snapshot_tree))}
	end

	# # Leave this 
	# def diff_snapshots(node_id1, node_id2)
	# end

	# If a branch_name is given, then return the branch_head ID
	# else just return current HEAD ID
	def self.get_head(branch_name=nil)
		head = File.open(@@head_dir, 'r'){|f| f.read}
		@@snapshot_tree = Marshal.load(File.binread(@@store_dir))
		if branch_name.nil?
			return head
		else
			branch_head = @@snapshot_tree.snapshots.find{|x| x.branch_name == branch_name || x.branch_HEAD == true}
			return branch_head.snapshot_ID
		end
	end


	# save text file to .octopus/communication
	def self.get_latest_snapshots(snapshot_ID)

		@@snapshot_tree = Marshal.load(File.binread(@@store_dir))
		snapshot = @@snapshot_tree.findNode(snapshot_ID)
		latest_snaps = @@snapshot_tree.snapshots.find_all {|x| snapshot_ID < x.snapshot_ID || snapshot.branch_name == x.branch_name}

		text_file = {
					"branch_name" => "#{snapshot.branch_name}"
					}
		latest_snaps.each_with_index{ |snap,index|
			text_file["snapshot_#{snap.snapshot_ID}"] = {"committed_time" => "#{snap.commit_time}"}
			snap.repos_hash.each_with_index do |(file, id), index2|
				text_file["snapshot_#{snap.snapshot_ID}"]["files_#{index2+1}"] = {"#{file}" => "#{Revlog.get_file(id)}"}
			end
		}

		snapshots_data = Marshal.dump(text_file)		
		File.open(text_file_dir, 'wb') { |f| f.puts snapshots_data}

	end

	# return "store" in /repo
	# Use Marshal.load to open "store"

	def self.get_all_snapshots
		all_snapshots = Marshal.load(File.binread($store_dir))
		return all_snapshots
	end

	# read text_file from Push and Pull module
	# and update snapshots tree
	def self.update_tree(text_file)
		@@snapshot_tree = Marshal.load(File.binread($store_dir))
		snapshots_data = Marshal.load(File.binread($text_file_dir))

		branch_name = snapshots_data["branch_name"]
		snapshots_only = snapshots_data.select {|key, value| key.match(/^snapshot_\d+/)}
		# Simply replace the old branch
		if @@snapshot_tree.branches.include(branch_name)
			delete_branch(branch_name)
		end
		@@snapshot_tree.branches.push(branch_name)
		# snap will be string like "snapshot_1", "snapshot_2"
		# only get number from it
		snapshots_only.each_with_index {|(snap, info),index|
			snapshot = @@snapshot_tree.snapshots.add_snapshot(snap.scan(/\d/).join(''))
			if index == 0
				snapshot.branch_HEAD = true
			end
			snapshot.commit_time = snapshots_only["#{snap}"]["committed_time"]
			files_only = snapshots_only[snap].select {|key, value| key.match(/^files_\d+/)}
			files_only.each {|file, contents|
				snapshot.repos_hash["#{file}"] = Revlog.add_file(contents)
			}

		}

	File.open($store_dir, 'wb'){|f| f.write(Marshal.dump(@@snapshot_tree))}

	end

	# handle merging two files 
	# Assume snapshot_ID1 here is the current branch 
	def self.merge(ancestor_ID, snapshot_ID1, snapshot_ID2)
		@@head = File.open(@@head_dir, 'r'){|f| f.read}
		@@snapshot_tree = Marshal.load(File.binread($store_dir))
		# find two snapshot
		snapshot_first = @@snapshot_tree.find_snapshot(snapshot_ID1)
		snapshot_second = @@snapshot_tree.find_snapshot(snapshot_ID2)

		# create new merged snapshot
		snapshot = @@snapshot_tree.add_snapshot
		# record branch name
		snapshot.branch_name = snapshot_first.branch_name
		# record time
		snapshot.commit_time = Time.now

		snapshot.add_parent(snapshot_first)
		snapshot.add_parent(snapshot_second)
		snapshot_first.add_child(snapshot)
		snapshot_second.add_child(snapshot)

		# for repos_hash,
		# call merge in Revlog to get new hashed ID
		merged_hash = snapshot_first.repos_hash
		merged_hash = merged_hash.merge!(snapshot_second.repos_hash) { |key, v1, v2| Revlog.merge(v1, v2) }
		snapshot.repos_hash = merged_hash

		@@head = snapshot.snapshot_ID

		File.open(@@head_dir, 'w'){ |f| f.write ("#{@@head}")}
		File.open($store_dir, 'wb'){|f| f.write(Marshal.dump(@@snapshot_tree))}

		return snapshot.snapshot_ID

	end

	# Get branch head
	def self.get_ancestor(snapshot_ID1, snapshot_ID2)

		@@snapshot_tree = Marshal.load(File.binread($store_dir))
		snapshot1 = @@snapshot_tree.find_snapshot(snapshot_ID1)
		snapshot2 = @@snapshot_tree.find_snapshot(snapshot_ID2)

		ancestor = @@snapshot_tree.snapshots.find{|x| x.branch_HEAD == true || x.branches.include?(snapshot1.branch_name) && x.branches.include?(snapshot2.branch_name)}

		return ancestor

	end

end

# Test
# r = Repos.new
# r.init
