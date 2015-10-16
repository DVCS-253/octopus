require "test/unit"
# snapshot.dat is a structure to save snapshot, with files and their version_no in order to tracking
# history
require "snapshot.dat"

class Unit_Test < Test::Unit::TestCase

	# Test for storing snapshot
	# input files and their version_no and save them into a snapshot.dat
	# files is like a list including all the files user want to commit
	# 
	def test_store_snapshot(path, files, version_no, expected_files):
		store_snapshot(path, file_list, version_no)
		assert_equal(files in path/snapshot.dat == expected_files)
		assert_equal(files.version_no in path/snapshot.dat == expected_files.version_no)
	end

	#Test for creating repo
	#create .repo as repository 
	def test_init(path):
		init(path)
		assert_equal(true, Dir.exist(.repo))
	end

	# Test file_path
	# return file path by file and version_no
	def test_file_path(file, version_no, expected_path):
		assert_equal(true, file_path(file, version_no), expected_path)
	end

	#Test for branching
	#Make sure we create the branch with 'name' and it has all files from master repo
	def test_branching(path, name):
		branching(name)
		assert_equal(true, Dir.exist(name))
		assert_equal(true, files in branch_path/snapshot.dat == files in path/snapshot.dat)
	end

	# Test for merging
	# Merge different branches, this is a kind of unspecific comparison here
	# If there is no conflit, simple merge files. For examples, different people modified different parts
	# of the file, just merge everything. If diff people modified the same part of the file, it will
	# save both modification 
	# 
	def test_merging(path, name):
		original_files = files in path/snapshot.dat
		merging(name)
		assert_equal(true, files in path/snapshot.dat == (files in merge_path/snapshot + original_files))
	end 

