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
		@snapshots = []
		@current_branch = "master"
	end	

	def find_snapshot(snapshot_ID)
		# time we are looking for
		p "old id" + snapshot_ID.to_s
		s = Marshal::load(snapshot_ID)
		p "looking for" + s.commit_time.to_s
		for snapshot in @snapshots
			p snapshot.commit_time.to_s
			if snapshot.commit_time.to_s == s.commit_time.to_s
				p "FOUND"
				return snapshot
			end
		end
		# Returns nil if the snapshot cannot be found
		return nil
	end

	def add_snapshot(commit_msg, root, branch_name, latest_commit=nil)
		snapshot = Snapshot.new

		# Record commit time of this commit
		snapshot.commit_time = Time.now

		# Record the commit msg
		snapshot.commit_msg = commit_msg

		# Record the branch name
		snapshot.branch_name = branch_name

		# Record if is the root
		snapshot.root = root
		# 
		if !latest_commit.nil?
			latest_commit.add_child(snapshot)
			snapshot.add_parent(latest_commit)
		end

		snapshot.snapshot_ID = Marshal::dump(snapshot) 
		@snapshots.push(snapshot)
		snapshot
	end

end

class Snapshot
	attr_accessor :snapshot_ID, :commit_msg, :repos_hash, :parent, :child, :root, :commit_time, :branch_name, :branch_HEAD

	def initialize
		@repos_hash = {}
		@parent = []
		@child = []
		@snapshot_ID = 0
	end

	def add_child(node)
		@child.push(node)
	end

	def add_parent(node)
		@parent.push(node)
	end

	# for branching
	def add_single_parent(node)
		@parent = []
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

	@@repo_dir = ".octopus/repo"
	@@comm_dir = ".octopus/communication"
	@@head_dir = File.join(@@repo_dir, "head")
	@@text_file_dir = File.join(@@comm_dir, "text_file")
	@@store_dir = File.join(@@repo_dir, "store")
	@@branch_dir = ".octopus/repo/branches"

	def self.init
		# For testing
		# Dir.mkdir("/Users/haochen/Desktop/test/.octopus")
		# Dir.mkdir("/Users/haochen/Desktop/test/.octopus/repo")

		# Created .octopus/repo on current directory
		# Dir.mkdir(File.join(Dir.pwd, ".octopus"), 0700)
		# Dir.mkdir(File.join(Dir.pwd, ".octopus/repo"), 0700)
		# Dir.mkdir(File.join(Dir.pwd, ".octopus/communication"), 0700)
		
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

	def self.make_snapshot(files_to_be_commits, commit_msg=nil)
		p files_to_be_commits.class
		@@snapshot_tree = Marshal.load(File.binread(@@store_dir))
		@@head = File.open(@@head_dir, 'r'){|f| f.read}

		if @@head == "0"
			p "adding the first snapshot"
			snapshot = @@snapshot_tree.add_snapshot(commit_msg, true, "master")

			p "printing first snapshot"
			p snapshot
			p snapshot.snapshot_ID

			File.open(@@head_dir, 'wb'){ |f| f.write ("#{snapshot.snapshot_ID}")}
			# Updating the branch file -> by default the branch name is master
			update_branch_file("master", snapshot.snapshot_ID)
		else
			p "adding the non first snapshot"
			head_snapshot = Marshal.load(File.binread(@@head_dir))
			current_branch = head_snapshot.branch_name
			p head_snapshot
			puts "current branch " + current_branch

			# latest_branch is the latest commit on this branch
			# which means find last appearance snapshot with current branch name
			# just reverse array and find first appearance 
			r_ids = @@snapshot_tree.snapshots.reverse
			parent = restore_snapshot(@@head)

			# add new snapshot
			snapshot = @@snapshot_tree.add_snapshot(commit_msg, false, current_branch, parent)

			# Then head becomes this snapshot' ID
			File.open(@@head_dir, 'wb'){ |f| f.write ("#{snapshot.snapshot_ID}")}
		end

		files_to_be_commits.each do |file_path, content|
			# get basename, like "a.rb"
			file_name = File.basename(file_path)
			file_time = File.mtime(file_path)
			# send contents of each file and get file_id from Revlog
			# Save to hash with it's basename
			snapshot.repos_hash[file_path.to_s] = Revlog.add_file([content, file_time])
		end

		# Updating the branch file
		puts "testing repo hash"
		puts snapshot.repos_hash.to_a.inspect
		update_branch_file(current_branch, snapshot.snapshot_ID)

		p snapshot.branch_name
		p snapshot.repos_hash.to_a.inspect
		p "all snapshots #{@@snapshot_tree.snapshots.count}"

		File.open(@@store_dir, 'wb'){|f| f.write(Marshal.dump(@@snapshot_tree))}
		test_snapshot_tree
		get_latest_snapshots(@@snapshot_tree.snapshots[0].snapshot_ID)
		return snapshot.snapshot_ID
	end

	def self.test_snapshot_tree
		@@snapshot_tree = Marshal.load(File.binread(@@store_dir))
		p "TESTING SNAPSHOT TREE"
		unless @@snapshot_tree.snapshots.nil?
			puts  @@snapshot_tree.snapshots[0].repos_hash.to_a.inspect
		end
	end

	# returns a specific snapshot
	def self.restore_snapshot(snapshot_ID)
		@@snapshot_tree = Marshal.load(File.binread(@@store_dir))
		snapshot = @@snapshot_tree.find_snapshot(snapshot_ID)
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

	def self.update_branch_file(branch_name, head)
		# Record branch_name and HEAD's snapshot_ID
		branch_table = load_branch_file (@@branch_dir)
		branch_table[branch_name] = head
		puts "branch table: #{branch_table.to_a.inspect}"
		File.open(@@branch_dir, 'wb'){|f| f.write(Marshal.dump(branch_table))}
		branch_table2 = load_branch_file (@@branch_dir)
		branch_table2[branch_name] = head
		puts "Testing branch table: "
		puts branch_table[branch_name] == branch_table2[branch_name]
	end

	def self.load_branch_file (filename)	
		if File.file? (filename)
			branch_table = Marshal.load(File.binread(filename))
		else
			branch_table = {}
		end
	end

	def self.update_head_file(snapshot_ID)
		File.open(@@head_dir, 'wb'){ |f| f.write (snapshot_ID)}
	end

	def self.get_branches
		branch_table = load_branch_file
		arr = []
		branch_table.each do |branch_name, head|
			arr << branch_name
		end
		arr
	end

	# Make 1 child from current HEAD 
	def self.make_branch(branch_name)
		@@snapshot_tree = Marshal.load(File.binread(@@store_dir))
		head_snapshot = Marshal.load(File.binread(@@head_dir))

		# Find the old head snapshot
		parent = restore_snapshot(File.binread(@@head_dir))
		head_snapshot.commit_time = Time.now
		head_snapshot.add_single_parent(parent)
		# head_snapshot.branch_HEAD = true

		# changing the branch name
		head_snapshot.branch_name = branch_name

		# transfer current branch to this branch
		@@snapshot_tree.current_branch = branch_name

		# Update snapshot ID		
		head_snapshot.snapshot_ID = 0
		head_snapshot.snapshot_ID = Marshal::dump(head_snapshot)
		update_head_file(head_snapshot.snapshot_ID)

		# Update the parent
		parent.add_child(head_snapshot)

		@@snapshot_tree.snapshots.push(head_snapshot)

		# Update branch file
		update_branch_file(branch_name, head_snapshot.snapshot_ID)

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
		
		if branch_name.nil?
			return head
		else
			branch_table = load_branch_file(@@branch_dir)
			branch_table[branch_name]
		end
	end


	# save text file to .octopus/communication
	# In order to send latest snapshots from the common ancestor
	# snapshot_ID, head.branch_name and snapshot_ID.branch_name
	# should be the same, otherwise throw an error string
	# Output: an array of Marshall snapshot ids
	def self.get_latest_snapshots(snapshot_ID)
		snapshot_ancestor = Marshal.load(snapshot_ID)
		head = Marshal.load(get_head)

		if snapshot_ancestor.branch_name != head.branch_name
			return "error from get last snapshots - unmatched branch name"
		else
			@@snapshot_tree = Marshal.load(File.binread(@@store_dir))
			latest_snaps = @@snapshot_tree.snapshots.find_all {|x| snapshot_ancestor.commit_time.to_i < x.commit_time.to_i  && snapshot_ancestor.branch_name == x.branch_name}

			array = []
			latest_snaps.each do |x|
				array << x.snapshot_ID
			end
			puts array.inspect
			File.open(@@text_file_dir, 'wb'){|f| f.write(Marshal.dump(array))}
		end
	end

	# return "store" in /repo
	# Use Marshal.load to open "store"
	def self.get_all_snapshots
		all_snapshots = Marshal.load(File.binread(@@store_dir))
		return all_snapshots
	end

	# read text_file from Push and Pull module
	# and update snapshots tree
	def self.update_tree(text_file)
		head = Marshal.load(File.binread(@@head_dir))
		head_snapshot = restore_snapshot(head)
		snapshots_data = Marshal.load(File.binread(text_file))
		@@snapshot_tree = Marshal.load(File.binread(@@store_dir))

		snapshots_data.each do |snapshot|
			@@snapshot_tree.snapshots.push(snapshot)
		end

		# Connect the ancestor head to the first element in the snapshot data and vice versa
		first_element = find_snapshot(snapshots_data[0].snapshot_ID)
		head_snapshot.add_child(first_element)
		first_element.add_parent(head_snapshot)

		# Reset the head and the branch file
		new_id = find_snapshot(snapshots_data.last.snapshot_ID)
		update_head_file(new_id)
		update_branch_file(head_snapshot.branch_name, new_id)

		# Store the updates tree array
		File.open(@@store_dir, 'wb'){|f| f.write(Marshal.dump(@@snapshot_tree))}

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
