require_relative "repos"
# require_relative "revlog"
require "test/unit"

# CSC 253 - DVCS Project
# Updated Unit Test for Repos
# 11/5/2015

class Test_Repos < Test::Unit::TestCase

    ############################################################################

	# General ideas of Repos
	# Contains snapshots that record history of each commit,
	# So users are able to get whatever history they want with
	# contents of files with Revlog module

	# Dependency:
	# Revlog: is sued to store the contents of the committed files and obatain a file_id

	# data structure for Repos is a tree
	# Every node in the tree represents one snapshot/commit with its node_id
	# Specifically, for each Node, it has
	#  1.a snapshot_ID
	#  2.a hashtable which contains the title of files and a file_ID generated
	# by Revlog module


	############################################################################

	# global variables that will be used in future test
	# $Username is just username
	# $init_path is the directory to initialize Repo
	# $repo_path is the directory of Repo

	def setup
		@init_path = "/Users/haochen/Desktop/test"
		@repo_path = "/Users/haochen/Desktop/test/.octupus/repo"
	end

	############################################################################

	# Test the initialization of the repos
	# Input is $init_path created before

	def test_init
		
		# make the directory to be the test area I want
		# Dir.chdir(@init_path)
		# call init to create repos with the name ".oct"
		Repos.init
		# make sure init() worked normally
		assert_equal(true, File.directory?(@repo_path))


	end


	# # Test make_snapshot, record version ids of a list of files 
	# # and the corresponding reference id to communicate with Revlog

	# def test_make_snapshot
	# 	# Call make_snapshot() function, it will always take stage in workspace as parameter
	# 	# Create version id for each file and file id in order to communicate with Revlog
	# 	# Created a new file to workspace and add
	# 	Dir.chdir(@init_path)
	# 	File.open("test1.txt", 'w'){|f| f.puts("First line")}
	# 	# Call function in workspace module
	# 	@files_to_be_commits = stage("test1.txt")
	# 	# Then call make_snapshot with the snapshot 1
	# 	@node_id1 = make_snapshot(@files_to_be_commits)
		
	# 	# Make sure ID is 1
	# 	assert_equal(@node_id1.snapshot_ID, 1)

	# 	# Modify test1.txt and create another snapshot
	# 	File.open("test1.txt", 'w'){|f| f.puts("Second line")}
	# 	# make another snapshot with name node_id2
	# 	@node_id2 = make_snapshot(@node_id1, @files_to_be_commits)
		
	# 	# Make sure this snapshot's ID is 2
	# 	assert_equal(@node_id2.snapshot_ID, 2)

	# 	# Test tree's functionality
	# 	assert_equal(@node_id1.child, @node_id2)
	# 	assert_equal(@node_id2.parent, @node_id1)

	# 	# Test root
	# 	assert_equal(@node_id1.root, true)
	# 	assert_equal(@node_id2.root, false)
		

	# end

	# # Test restore_snapshot, which takes a node_id that represents a Snapshot
	# # and return list of file_id's

	# # Since file_id is generated by Revlog, Repos has no idea what the file_id
	# # will be. 

	# # So test here is trying to call get_file function in Revlog and make sure
	# # Repos returns the right Snapshot
	# def test_restore_snapshot
	# 	# Try to restore the first snapshot, only have one file
	# 	@file_id = restore_snapshot(@node_id1)
	# 	# call Revlog to verify if it's the first snapshot's 
	# 	assert_equal(get_file(@file_id), "First line")

	# 	#Restore the second snapshot
	# 	@file_id = restore_snapshot(@node_id2)
	# 	assert_equal(get_file(@file_id), "First Line" + "\n" + "Second Line")

	# end


	# # Test history, which takes a specific Snapshot's node_id and return all
	# # parent of this node, which are all histories.
	# def test_history
	# 	# Find history of the latest node_id
	# 	@list_of_node_ids = history(@node_id1)
	# 	# Only have one history, which is the first snapshot
	# 	assert_equal(@list_of_node_ids = [1])

	# 	@list_of_node_ids = history(@node_id2)
	# 	assert_equal(@list_of_node_ids = [1,2])

	# end

	# # Test make_branch, which takes a specific node_id and make_branch make a new Snapshot
	# # from that Snapshot
	# def test_make_branch
	# 	# After call make_branch on second Snapshot, we will see two folders in node_id1
	# 	@node_id12 = make_branch(@node_id11)
	# 	# go to node_id1 folder
	# 	Dir.chdir(@repo_path + "/" + "node_id1")
	# 	# Find folder names and save into an array, which will equal to two branches' node ids
	# 	@folders_name_array = Dir.glob('*').select{|f| File.directory? f}
	# 	assert_equal(@folders_name_array, ["node_id11", "node_id12"])

	# end

	# # Test delete_branch, which takes a specific node_id and delete this Snapshot
	# def test_delete_branch
	# 	# Delete the branch of node_id11
	# 	delete_branch(@node_id12)
	# 	# Find folder name again, now we only have node_id11
	# 	@folders_name_array = Dir.glob('*').select{|f| File.directory? f}
	# 	assert_equal(@folders_name_array, ["node_id11"])


	# end

	# # Test diff_snapshots, which takes two different snapshots and return list of file
	# # changes by calling Revlog
	# def test_diff_snapshots
	# 	# This function will call Revlog using file_id
	# 	@diff_contents = diff_snapshots(node_id1, node_id11)
	# 	assert_equal(@diff_contents, "Second line")


	# end

	# # Test merge, which takes two different node_id and call Revlog and return a new Snapshot
	# def test_merge
	# 	# Re-create the branch of node_id11 and add a new line to test1.txt
	# 	@node_id12 = make_branch(@node_id11)
	# 	Dir.chdir(@repo_path + "/" + @node_id1 + "/" + @node_id12)
	# 	File.open("test1.txt", 'w'){|f| f.puts("Third line")}
		
	# 	# Merge node_id11, node_id12
	# 	@node_id_merged = merge(@node_id11, @node_id12)
	# 	@diff_contents = diff_snapshots(node_id_merged, @node_id11)
	# 	assert_equal(@diff_contents, "Third line")
		

	# end

end
