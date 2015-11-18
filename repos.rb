# CSC 253 - DVCS Project 
# Repos implementation
# 11/18/2015 

require_relative 'revlog'
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
	attr_accessor :snapshot_ID, :repos_hash, :parent, :child, :root, :commit_time, :branch_name

	def initialize(snapshot_ID)
		@snapshot_ID = snapshot_ID
		@repos_hash = Hash.new
		@parent = Array.new
		@child = Array.new
		@root = nil
		@commit_time = Time.new
		@branch_name = "Master"
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

	# Initialize the repos directory

	def init()
		Dir.mkdir(File.join(Dir.pwd, ".octopus/repo"), 0700)
		$snapshot_tree = Tree.new
		$last_commit = Snapshot.new(nil)
	end


	# make_snapshot function
	# files_to_be_commits will be a list with file names
	# Read the latest commit

	# if nil, which means this is the first commit
	# which will be the root of the tree
	# Set snapshot ID to 1 and make .root = true

	# if not nil, make this commit be the child of 
	# last commit on this branch

	def make_snapshot(files_to_be_commits)
		if $last_commit == nil
			snapshot = $snapshot_tree.add_snapshot(1)
			snapshot.commit_time = Time.now
			snapshot.root = true
			$last_commit = snapshot
		else

			# latest_branch is the latest commit on this branch
			r_ids = snapshots.reverse
			latest_branch = r_ids.find{|x| x.branch_name == $current_branch}

			# add one on last snapshot_ID to make a new one
			snapshot = $snapshot_tree.add_snapshot($last_commit + 1)
			# save commit time
			snapshot.commit_time = Time.now
			latest_branch.add_child(snapshot)
			snapshot.add_parent(latest_branch)
			latest_branch = snapshot
		end
		for file_title in files_to_be_commits
			# Call add_file_content in revlog to add file
			snapshot.repos_hash[file_title] = add_file_content(File.read(file_title))
		end
	end

	# returns a specific snapshot

	def restore_snapshot(snapshot_ID)

		snapshot = find_snapshot(snapshot_ID)
		# put file_id into file_id_lists
		snapshot.repos_hash.each do |name, id|
			file_id_lists << id
		end
		return file_id_lists
	end

	# returns all parents of certain node_id

	def history(snapshot_ID)
		# First find that snapshot
		snapshot = find_snapshot(snapshot_ID)
		history_helper(snapshot)
		# add root snapshot_id, which is 1 to list of ids.
		list_of_snapshots << 1
		# since this method will duplicate count snapshots
		# use .uniq to remove any duplicate
		list_of_snapshots = list_of_snapshots.uniq

		return list_of_snapshots
	end

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

	# Make 2 children 
	def make_branch(snapshot_ID, name)
		snapshot = findNode(snapshot_ID)
		# If snapshot ID is 5, then two branches will be 51 and 52
		snapshot_master = snapshot.add_snapshot(snapshot_ID*10 + 1)
		snapshot_branch = snapshot.add_snapshot(snapshot_ID*10 + 2)
		# save time
		snapshot_master.commit_time = Time.now
		snapshot_branch.commit_time = Time.now
		# copy hash table
		snapshot_master.repos_hash = snapshot.repos_hash
		snapshot_branch.repos_hash = snapshot.repos_hash
		# record branch name
		snapshot_branch.branch_name = name
		# Switch to the branch just created
		$current_branch = name


		snapshot_branch_master.add_parent(snapshot)
		snapshot_branch_branch.add_parent(snapshot)
		snapshot.add_child(snapshot_branch_master)
		snapshot.add_child(snapshot_branch_master)

		jhash = {"#{branch_name}" => "#{snapshot_ID}"}
		File.open(".oct/branch/branches", "w") do |f|
			f.write(jhash.to_json)
		end

	end

	# means delete the whole branch? 
	def delete_branch(snapshot_ID)

		# Find branch name with snapshot_ID
		snapshot = findNode(snapshot_ID)
		branch_to_delete = snapshot.branch_name

		# Delete all snapshots with this branch name
		snapshots.delete{|x| x.branch_name == branch_to_delete}
	end

	# Leave this 
	def diff_snapshots(node_id1, node_id2)

	end

	def get_latest_snapshots(snapshot_ID)
		snapshot = findNode(snapshot_ID)
		this_ID = snapshot.snapshot_ID
		latest_snaps = snapshots.find_all {|x| this_ID < x.snapshot_ID || snapshot.branch_name == x.branch_name}

		File.open('text_file', 'w'){ |f|
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


end