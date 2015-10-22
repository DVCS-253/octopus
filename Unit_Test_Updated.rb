require "test/unit"

# CSC 253 - DVCS Projects 
# Updated Unit Test for Repos
# Almost rewrite everything 
# 10/20/2015

class Test_Repos < Test::Unit::TestCase

	# Create values that will be used 
	# later in the test

	# @init_path used for where the DVCS 
	# will be initialized
	# @repo_path is repos directory
	
	# @xxx_s is all plain-text, value
	# is the directory in repos
	# HEAD: a referrence to the branch user is working with
	# COMMIT_EDITMSG: last commit message
	# config: the configuration file, includes information such as remote, branch
	# FETCH_HEAD: record of information when fetching the branch

	# branches: a file used to specify a URL to fetch, pull and push
	# logs: File records changes made to refs
	# refs: File with heads and remotes, similar structure as remotes,
	# but only records latest commit
	# objects: record all contents user ever checked, commits
	# Store the diff and save with a random nodeID in a hash database Save_file
	# For this maybe the Revlog's Job?
	# and another database Snapshot, it 
	# to save all files' diff
	# for the subdirectory and next 38 chars are the filename


	def setup
		@Username = "CSC253"
		@init_path = "Desktop/DVCS/Test"
		@repo_path = "Desktop/DVCS/Test/.git"

		@branch_path = "Desktop/DVCS/Branching"

		@head_s = "/HEAD"
		@commit_msg_s = "/COMMIT_EDITMSG"
		@config_s = "/config"
		@fetch_head_s = "/FETCH_HEAD"

		@branches = "/branches"
		@logs = "/logs"
		@objects = "/objects"
		@refs = "/refs"
		@remotes = "/remotes"

		@first_commit_msg = "first commit's comment"
		@second_commit_msg = "second commit's comment"

		@head_msg = "ref: refs/heads/master"
		@head_branch_msg = "ref: refs/heads/second"

		@first_nodeID = 10
		@second_nodeID = 20

		@first_text = "first commit"
		@second_text = "second commit"

		@test1
		@test2


		@result = []


		
	end

	# Test the initialization of the repos
	# Input is @init_path created before
	def test_init()
		# make the directory to be the test
		# area I want
		Dir.chdir(@init_path)
		
		# call init to create repos with the name ".git"
		init()

		# make sure init() worked normally
		# create all files user needs
		assert_equal(true, File.directory?(@repo_path))
		assert_equal(@init_path, File.dirname(@repo_path))

		assert_equal(true, File.exist?(@repo_path + @head_s))
		head_actual_msg = File.open("HEAD").read
		assert_equal(head_actual_msg, @head_msg)

		assert_equal(true, File.exist?(@repo_path + @config_s))
		# assert_equal(true, File.exist?(@repo_path + @fetch_head_s))

		assert_equal(true, File.directory?(@repo_path + @branches))
		# assert_equal(true, File.directory?(@repo_path + @logs))
		# assert_equal(true, File.exist?(@repo_path + @logs + "/HEAD"))
		# assert_equal(true, File.directory?(@repo_path + @logs + @refs + "/heads"))
		# assert_equal(true, File.directory?(@repo_path + @logs + @refs + "/remotes"))
		assert_equal(true, File.directory?(@repo_path + @objects + "/Snapshot"))
		assert_equal(true, File.directory?(@repo_path + @refs))
		assert_equal(true, File.directory?(@repo_path + @refs + "/heads"))
		# assert_equal(true, File.directory?(@repo_path + @refs + "/remotes"))

	end

	# Test the commit function
	# Files are files that user want to commit in workspace
	# commit_msg is user's comment for this commit
	# Everytime user commit, DVCS saves all files in repo to Snapshot, with a certain nodeID
	def test_commit(commit_msg)
		########################BEGIN THE FIRST COMMIT###############################
		dir.chdir(@init_path)
		commit(@first_commit_msg)

		# After first commit, user will have file to save latest comment
		# Pretend we commit one single file one time
		assert_equal(true, File.exist?(@repo_path + @commit_msg_s))
		first_commit_text = File.open("COMMIT_EDITMSG").read
		assert_equal(first_commit_text, @first_commit_msg)

		# Test whether save test with nodeID
		# 
		Dir.chdir(@repo_path + @objects)
		Snapshot.each do |key, file|
			nodeID = key
			assert_equal(true, key.is_a?)
		end
		assert_equal(Snapshot[nodeID], test)

		# Test HEAD in logs
		Dir.chdir(@repo_path + @logs)
		assert_equal("10 CSC253 commit (initial): first commit", File.open("HEAD").read)

		# Test master branch in /logs/refs/heads
		# Since we commit on master branch, shoulde be same as HEAD in logs
		Dir.chdir(@repo_path + @logs + @refs + "/heads")
		assert_equal("10 CSC253 commit (initial): first commit", File.open("master").read)

		# Test master branch in /refs/heads
		# Only records lastest comment
		Dir.chdir(@repo_path + @refs + "/heads")
		assert_equal("10", File.open("master").read)

		########################DONE WITH THE FIRST COMMIT###############################

		########################BEGIN THE SECOND COMMIT###############################
		Dir.chdir(@init_path)
		commit(@second_commit_msg)

		# Test whether comment in COMMIT_EDITMSG has been updated
		second_commit_text = File.open("COMMIT_EDITMSG").read
		assert_equal(second_commit_text, @second_commit_msg)

		# Make sure we have save the whole repos 
		Dir.chdir(@repo_path + @objects)
		Save_file.each do |key, content|
			@result << key
		end
		assert_equal(true, @result.include? @second_nodeID)


	end

	# Return context of a file with NodeID 
	# This should be Revlog?
	def test_history (NodeID)
		first_history = history (@first_nodeID)
		assert_equal("first_comment", first_history)

		second_history = history (@second_nodeID)
		assert_equal("second_commit", second_history)

	end

	# ID created when did a commit, this will return files that time
	def test_Snapshot (NodeId)
		assert_equal(Snapshot(first_nodeID), test1)
		assert_equal(Snapshot(second_nodeID), test2)


	# Test Branching
	# Create a new branch "Similar to checkout in Git"
	def test_branching (branch_name)
		Dir.chdir(@init_path)
		branching(second)

		# Switch to second branch
		Dir.chdir(@repo_path)
		assert_equal(@head_branch_msg, File.open("HEAD").read)

		Dir.chdir(@repo_path + @logs + @refs + "/heads")
		assert_equal(true, File.exist?("second"))

		Dir.chdir(@repo_path + @refs + "/heads")
		assert_equal(true, File.exist?("second"))

	end

end
