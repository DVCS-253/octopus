# CSC 253 - DVCS Project 
# Repos implementation
# 11/5/2015 - first try
require "revlog"

class Repos

	############################################################################

	# General ideas of Repos
	# Contains snapshots that record history of each commit,
	# So users are able to get whatever history they want with
	# contents of files with Revlog module

	# Dependency:
	# Revlog: is sued to store the contents of the committed files and obatain a file_id

	# data structure for Repos is a tree, named it MANIFEST
	# Every node in the tree represents one snapshot/commit with its node_id
	# Specifically, for each Node, it has
	#  1.a snapshot_ID
	#  2.a hashtable which contains the title of files and a file_ID generated
	# by Revlog module

	############################################################################

	$latest_commit = nil

	# For Tree structrue
	# Node has snapshot_ID, repos_hash with file_title and file_id

	class Node
		attr_accessor :snapshot_ID, :repos_hash, :parent, :child, :root
		def initialize(snapshot_ID)
			@snapshot_ID = snapshot_ID
			@repos_hash = nil
			@parent = nil
			@child = nil
			@root = false

		end	
	end

	# Initialize the repos directory

	def init()
		Dir.mkdir(File.join(Dir.pwd, ".oct"), 0700)
	end

	# make_snapshot function
	# files_to_be_commits will be a list with file names
	# Read the latest commit
	# if nil, which means this is the first commit
	# which will be the root of the tree
	# Set snapshot ID to 1 and make .root = true

	# if not nill, make last_commit's child be this commit
	# and this commit's parent is the last commit

	def make_snapshot(last_commit=nil, files_to_be_commits)
		if last_commit == nil
			snapshot = Node.new(1)
			snapshot.root = true
			$latest_commit = snapshot
		else
			# Add one on last snapshot_ID to make a new one
			snapshot = Node.new(last_commit.snapshot_ID + 1)
			last_commit.child = snapshot
			snapshot.parent = last_commit
			$latest_commit = snapshot
		end
		for file in files_to_be_commits
			# Call add_file in revlog to add file
			snapshot.repos_hash[file] = add_file (file)
		end
	end

	# returns a specific snapshot

	def restore_snapshot(node_id)
		# Keep going up from the latest_commit
		snapshot = $latest_commit
		while snapshot.snapshot_ID != node_id
			snapshot = snapshot.parent
		end
		# put file_id into file_id_lists
		snapshot.repos_hash.each do |name, id|
			file_id_lists << id
		end
		return file_id_lists
	end

	# returns all parents of certain node_id

	def history(node_id)
		# First find that snapshot
		snapshot = $latest_commit
		while snapshot.snapshot_ID != node_id
			snapshot = snapshot.parent
		end
		# now snapshot is the snapshot to find history
		while snapshot.parent != nil
			list_of_node_ids << snapshot.snapshot_ID
			snapshot = snapshot.next
		end
		return list_of_node_ids
	end

	def make_branch(node_id)

	end

	def delete_branch(node_id)

	end

	def diff_snapshots(node_id1, node_id2)

	end

	def merge(node_id1, node_id2)

	end


end