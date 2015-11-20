# CSC 253 - DVCS Project 
# Repos implementation
# 11/18/2015 

# require_relative 'revlog'
require 'json'

# For Tree structrue
# Tree class and Snapshot class (represents nodes in the tree)


# Snapshot(node) has snapshot_ID, repos_hash with file_title and file_id
# parent(last commit), child (next commit)

class Tree
	$last_commit = nil
	$current_branch = "Master"

	attr_accessor :snapshots

	def initialize()
		@snapshots = Array.new
	end	

	def find_snapshot(snapshot_ID)
		for snapshot in @snapshots
			if snapshot.snapshot_ID == snapshot_ID
				return snapshot
			end
		end

		raise "Unable to find Snapshot with snapshot_id #{snapshot_id1}"
	end

	def add_snapshot(snapshot_ID)
		snapshot = Snapshot.new(snapshot_ID)
		@snapshots.push(snapshot)
		return snapshot
	end

end

class Snapshot
	attr_accessor :snapshot_ID, :repos_hash, :parent, :child, :root, :commit_time, :branch_name, :branch_HEAD, :branches

	def initialize(snapshot_ID)
		@snapshot_ID = snapshot_ID
		@repos_hash = Hash.new
		@parent = Array.new
		@child = Array.new
		@root = false
		@commit_time = Time.new
		@branch_name = "Master"
		@branch_HEAD = false
		@branches = Array.new
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

	def init

		# For testing
		# Dir.mkdir("/Users/haochen/Desktop/test/.octopus")
		# Dir.mkdir("/Users/haochen/Desktop/test/.octopus/repo")

		# Created .octopus/repo on current directory
		Dir.mkdir(File.join(Dir.pwd, ".octopus"), 0700)
		Dir.mkdir(File.join(Dir.pwd, ".octopus/repo"), 0700)
		Dir.mkdir(File.join(Dir.pwd, ".octopus/communication"), 0700)
		$repo_dir = File.join(Dir.pwd, ".octopus/repo")
		$comm_dir = File.join(Dir.pwd, ".octopus/communication")
		# Created snapshot_tree
		$snapshot_tree = Tree.new

		# Marshal dump
		$store_dir = File.join($repo_dir, "store")
		File.open($store_dir, 'wb'){|f| f.write(Marshal.dump($snapshot_tree))}
		# $last_commit is HEAD
		$last_commit = Snapshot.new(nil)

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

	def make_snapshot(files_to_be_commits)
		if $last_commit.snapshot_ID == nil
			snapshot = $snapshot_tree.add_snapshot(1)
			# Record commit time of this commit
			snapshot.commit_time = Time.now
			snapshot.root = true
			$last_commit = snapshot
		else
			# latest_branch is the latest commit on this branch
			# which means find last appearance snapshot with current branch name
			# just reverse array and find first appearance 
			r_ids = $snapshot_tree.snapshots.reverse
			latest_branch = r_ids.find{|x| x.branch_name == $current_branch}

			# add one on last snapshot_ID to make a new one
			snapshot = $snapshot_tree.add_snapshot($last_commit.snapshot_ID + 1)
			# Record commit time of this commit
			snapshot.commit_time = Time.now

			latest_branch.add_child(snapshot)
			snapshot.add_parent(latest_branch)
			# Then $last_commit(HEAD) becomes this snapshot
			$last_commit = snapshot
		end
		for file in files_to_be_commits
			# get basename, like "a.rb"
			file_name = File.basename(file)
			# send contents of each file and get file_id from Revlog
			# Save to hash with it's basename
			snapshot.repos_hash[file_name] = Revlog.add_file(File.read(file))
		end
		return snapshot.snapshot_ID
	end

	# returns a specific snapshot

	def restore_snapshot(snapshot_ID)

		snapshot = $snapshot_tree.find_snapshot(snapshot_ID)
		
		# # put file_id into file_id_lists
		# file_id_lists = Array.new
		# snapshot.repos_hash.each do |file_dir, file_id|
		# 	file_id_lists << file_id
		# end

		return snapshot
	end

	# returns all parents of certain node_id

	def history(snapshot_ID)
		# First find that snapshot
		snapshot = $snapshot_tree.find_snapshot(snapshot_ID)
		list_of_snapshots = Array.new
		history_helper(snapshot)
		# add root snapshot_id, which is 1 to list of ids.
		list_of_snapshots << 1
		# since this method will duplicate count snapshots
		# use .uniq to remove any duplicate
		list_of_snapshots = list_of_snapshots.uniq

		return list_of_snapshots
	end

	# helper to find all histories
	def history_helper(snapshot)
		while snapshot.root != true
			# If only one parent, just add it to list
			if snapshot.parent.length == 1
				list_of_snapshots << snapshot.parent[0].snapshot_ID
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
	def make_branch(branch_name)

		# Make a Json file in repo named "branches.json"
		json_dir = File.join(repo_dir, "branches.json")
		# Record branch_nam and HEAD's snapshot_ID
		jhash = {"#{branch_name}" => "#{$last_commit.snapshot_ID}"}
		File.open(json_dir, "w") do |f|
			f.write(jhash.to_json)
		end

		snapshot_branch = $snapshot_tree.add_snapshot($last_commit.snapshot_ID + 1)
		snapshot_branch.branch_name = branch_name
		snapshot_branch.branch_HEAD = true

		$last_commit.add_child(snapshot_branch)
		snapshot_branch.add_parent($last_commit)
		snapshot_branch.repos_hash = $last_commit.repos_hash

		$last_commit.push(branch_name)

		# transfer to this branch
		$current_branch = branch_name
		$last_commit = snapshot_branch

	end

	# means delete the whole branch? 
	def delete_branch(branch_name)

		# Delete all snapshots with this branch name
		snapshot_tree.snapshots.delete{|x| x.branch_name == branch_name}
	end

	# # Leave this 
	# def diff_snapshots(node_id1, node_id2)

	# end

	# If a branch_name is given, then return the branch_head ID
	# else just return current HEAD ID
	def get_head(branch_name=nil)
		if branch_name.nil?
			return $last_commit.snapshot_ID
		else
			head = $snapshot_tree.snapshots.find{|x| x.branch_name == branch_name || x.branch_HEAD == true}
			return head.snapshot_ID
		end
	end

	# save text file to .octopus/communication
	def get_latest_snapshots(snapshot_ID)
		snapshot = findNode(snapshot_ID)
		latest_snaps = snapshots.find_all {|x| snapshot_ID < x.snapshot_ID || snapshot.branch_name == x.branch_name}

		text_file_dir = File.join(comm_dir, "text_file")

		File.open(text_file_dir, 'w'){ |f|
			f.puts "snapshot{"
			f.puts "	branch_name => #{snapshot.branch_name},"
			latest_snaps.each_with_index{ |item,index|
				f.puts "	snapshot_ID#{index+1} => #{snap.snapshot_ID}"
				f.puts "		files =>"
				i = 1
				repos_hash.each do |title, id|
					f.puts "			filename#{i} => #{title}"
					f.puts "				#{get_file(title)},"
					i += 1
				end
				f.puts "		},"

			}
			f.puts "}"
		}

	end

	# return "store" in /repo
	# Use Marshal.load to open "store"

	def get_all_snapshots
		all_snapshots = Marshal.load(File.binread($store_dir))
		return all_snapshots
	end

	# read text_file from Push and Pull module
	# and update snapshots tree
	def update_tree(text_file)


	end

	# handle merging two files
	def merge(snapshot_ID1, snapshot_ID2)
		# find two snapshot
		snapshot_first = find_snapshot(snapshot_ID1)
		snapshot_second = find_snapshot(snapshot_ID2)

		# create new merged snapshot
		snapshot = $snapshot_tree.add_snapshot($last_commit + 1)
		# record time
		snapshot.commit_time = Time.now

		snapshot.add_parent(snapshot_first)
		snapshot.add_parent(snapshot_second)
		snapshot_first.add_child(snapshot)
		snapshot_second.add_child(snapshot)

		# for repos_hash,
		# call merge in Revlog to get new hashed ID
		merged_hash = snapshot_first.repos_hash
		merged_hash = merged_hash.merge!(snapshot_second.repos_hash) { |key, v1, v2| merge(v1, v2) }
		snapshot.repos_hash = merged_hash

		return snapshot.snapshot_ID

	end

	# Get branch head
	def get_ancestor(snapshot_ID1, snapshot_ID2)
		snapshot1 = $snapshot_tree.find_snapshot(snapshot_ID1)
		snapshot2 = $snapshot_tree.find_snapshot(snapshot_ID2)

		ancestor = $snapshot_tree.snapshots.find{|x| x.branch_HEAD == true || x.branches.include?(snapshot1.branch_name) && x.branches.include?(snapshot2.branch_name)}

		return ancestor

	end

end

# Test
r = Repos.new
r.init
