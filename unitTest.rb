require_relative 'revlog'
require 'test/unit'


class Tests < Test::Unit::TestCase

	###########
	# Setup   #
	###########
	def setup
		@revlog = Revlog.new
		@test_file1 = File.new('test1.txt', "w") #create a test file
		@test_file1.puts("file1")
		@test_file1.close

		@test_file2 = File.new('test2.txt', "w") #create a second test file
		@test_file2.puts("file2")
		@test_file2.close
	end

	###########
	# Cleanup #
	###########
	def teardown
		# Destroy test files
		File.delete("test1.txt", "test2.txt")
	end



	#########################################################
	# Tests													#
	#########################################################

	############
	# add_file #
	############
	def test_add_file

		#stores two files
		#fails if the hash ids
		#returned are invalid
		#or the same

		id1 = @revlog.add_file(@test_file1) #call add_file
		assert_equal(Bignum, id1.class, "Invalid ID (1)")
		id2 = @revlog.add_file(@test_file2) #call add_file
		assert_equal(Bignum, id2.class, "Invalid ID (2)")
		assert_not_equal(id1,id2,"ID's were equal")

		test_arr = []
		rigor = 100
		rigor.times do |x|
			file = File.new("Foo"+x.to_s, "w")
			file.close
			test_arr.push(@revlog.add_file(file))
		end
		assert_nil(test_arr.detect{ |e| test_arr.count(e) > 1 }, "Duplicate ID's")
		rigor.times do |x|
			File.delete("Foo"+x.to_s)
		end
	end
	#########################################################
	# end add_file											#
	#########################################################


	############
	# get_file #
	############
	def test_get_file
		id1 = @revlog.add_file(@test_file1) #call add_file
		id2 = @revlog.add_file(@test_file2) #call add_file

		#loads the two files previously stored
		#fails if retrieved files are not original files

		assert_equal(@test_file1, @revlog.get_file(id1), "Unexpected file loaded (file 1)")
		assert_equal(@test_file2, @revlog.get_file(id2), "Unexpected file loaded (file 2)")
	end
	#########################################################
	# end get_file 											#
	#########################################################



	###############
	# delete_file #
	###############
	def test_delete_file
		id1 = @revlog.add_file(@test_file1) #call add_file
		id2 = @revlog.add_file(@test_file2) #call add_file

		#deletes the file previously stored
		#fails if deletion exits unsuccessfully
		#or if the file can be retrieved afterwards

		assert_equal(0, @revlog.delete_file(id1), "File deletion unsuccessful")
		assert_nil(@revlog.get_file(id1), "File not properly deleted")
		
	end
	#########################################################
	# end delete_file 										#
	#########################################################



	##############
	# diff_files #
	##############
	def diff_files

		#diff_files(fileA, fileB): returns a list of differences between the two files

		#tests to make sure a file diffed with
		#itself is unchanged, and that file diffs
		#involving partial/entire content work properly

		merge_file1 = File.new("merger1", "w") #create a test file
		merge_file1.puts("first\nfile\nanarchy")
		merge_file1.close

		merge_file2 = File.new("merger2", "w") #create a test file
		merge_file2.puts("file\nanarchy\nNaNarchy")
		merge_file2.close

		merge_file3 = File.new("merger3", "w") #create a test file
		merge_file3.puts("or else")
		merge_file3.close


		assert_nil(diff_files(@test_file1, @test_file1), "Self comparison faiure")

		assert_equal(diff_files(merge_file1, merge_file2), "first, NaNarchy", "Diff failure 1")

		assert_equal(diff_files(@test_file1, merge_file1), "file, or else", "Diff failure 2")

	end
	#########################################################
	# end diff_files 										#
	#########################################################



	#########
	# merge #
	#########
	def test_merge

		#merge(fileA, fileB): returns a merged file or conflict file plus a new file id

		#tests to make sure a file merged with
		#itself is unchanged, and that simple
		#and complex file merges work properly

		merge_file1 = File.new("merger1", "w") #create a test file
		merge_file1.puts("first\nfile\nanarchy")
		merge_file1.close

		merge_file2 = File.new("merger2", "w") #create a test file
		merge_file2.puts("file\nanarchy\nNaNarchy")
		merge_file2.close

		merge_file3 = File.new("merger3", "w") #create a test file
		merge_file3.puts("first\nfile\nanarchy\nNaNarchy")
		merge_file3.close

		merged = File.new("merged", "w") #create a test file
		merged.puts(">>merger1:1 first\nfile\n>>merger1:3 anarchy")
		merged.close


		assert_equal(merge(@test_file1, @test_file1)[0], @test_file1, "Self comparison faiure")

		assert_equal(merge(merge_file1, merge_file2)[0], merge_file3, "Simple merge failure")

		assert_equal(merge(@test_file1, merged)[0], merged, "Complex merge failure")


		assert_raise do
			get_file(merge(@test_file1, @test_file1)[1]) #id is not yet used
		end

		assert_raise do
			get_file(merge(merge_file1, merge_file2)[1]) #id is not yet used
		end

		assert_raise do
			get_file((merge(@test_file1, merger1)[1]) #id is not yet used
		end

	end
	#########################################################
	# end merge 											#
	#########################################################

end