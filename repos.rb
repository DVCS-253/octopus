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

	def make_snapshot(last_commit=nil, files_to_be_commits)
		if last_commit == nil
			snapshot = Node.new(1)
			snapshot.root = true
		else
			snapshot = Node.new(last_commit.snapshot_ID + 1)
			last_commit.child = snapshot
			snapshot.parent = last_commit
		end
		for file in files_to_be_commits
			# Call add_file in revlog to add file
			snapshot.repos_hash[file] = add_file (file)
		end
	end

	def restore_snapshot(node_id)
		while snapshot.snapshot_ID != node
			snapshot = snapshot.parent
		end
		snapshot.repos_hash.each do |name, id|
			file_id_lists << id
		end
		return file_id_lists
	end

	def history(node_id)

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