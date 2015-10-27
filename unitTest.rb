########
# test #
########

def test()
	############
	# add_file #
	############

	#add_file("filename"): stores specified file

	#creates a file and stores it
	#fails if an exception is raised

	test_file1 = File.new('test1.txt', "w") #create a test file
	test_file1.puts("file")
	test_file1.close
	assert_nothing_raised do
		add_file(test_file1)
	end

	#########################################################
	# end add_file											#
	#########################################################



	############
	# get_file #
	############

	#get_file("filename"): returns contents of specified file

	#loads the file previously stored
	#fails if retrieved file is not original file

	assert_equal(get_file('test1.txt'), "file", "Unexpected file loaded (file 1)")

	#########################################################
	# end get_file 											#
	#########################################################




	###############
	# delete_file #
	###############

	#delete_file("filename"): deletes specified file

	#deletes the file previously stored
	#fails if an exception is raised during deletion
	#or if the file can be retrieved without error afterwards

	assert_nothing_raised do
		delete_file('test1.txt')
	end
	assert_raise do
		get_file('test1.txt')
	end
	
	#########################################################
	# end delete_file 										#
	#########################################################



	#############
	# hash_file #
	#############

	#hash_file function
	#hash_file("filename"): returns hashcode for specified file
	#hash_fie(id): returns filename stored at specified hashcode
	
	#hashes a filename or returns a filename for a given hashcode
	#fails if id is not of correct form
	#fails if generates the same key for different strings
	#fails if hashcode returns an unexpected filename

	id1 = hash_file("foo1")
	id2 = hash_file("foo2")
	id3 = hash_file("foo3")

	assert_equal(/(key structure)/, id1, "Invaid hash id 1") #make sure id is of the right form
	assert_equal(/(key structure)/, id2, "Invaid hash id 2") #make sure id is of the right form
	assert_equal(/(key structure)/, id3, "Invaid hash id 3") #make sure id is of the right form
	assert_not_equal(id1, id2, "ID 1,2 were equal") #make sure id's are unique
	assert_not_equal(id1, id3, "ID 1,3 were equal") #make sure id's are unique
	assert_not_equal(id3, id2, "ID 2,3 were equal") #make sure id's are unique

	assert_equal(hash_file(id1), "foo1" "Unexpected string returned (id1)") #make sure hash retrieves correct string
	assert_equal(hash_file(id2), "foo2" "Unexpected string returned (id2)") #make sure hash retrieves correct string
	assert_equal(hash_file(id3), "foo3" "Unexpected string returned (id3)") #make sure hash retrieves correct string


	#rigorous tests to ensure id's are unique

	#test_arr = []
	#10000.times {test_arr.push(hash_file("foo"))}
	#assert_equal(test_arr.detect{ |e| test_arr.count(e) > 1 }, nil, "Duplicate ID's (constant)")

	test_foo = []
	10000.times {|x| test_foo.push(hash_file("foo"+ x.to_s))}
	assert_equal(test_foo.detect{ |e| test_foo.count(e) > 1 }, nil, "Duplicate ID's (variant)")

	#########################################################
	# end hash_file											#
	#########################################################


	##############
	# diff_files #
	##############

	#diff_files(fileA, fileB): returns a list of differences between the two files
	#diff_files("filenameA", "filenameB"): returns a list of differences between the two files

	#tests to make sure a file diffed with
	#itself is unchanged, and that file diffs
	#involving partial/entire content work properly

	merge_file1 = File.new('merger1', "w") #create a test file
	merge_file1.puts("first\nfile\nanarchy")
	merge_file1.close

	merge_file2 = File.new('merger2', "w") #create a test file
	merge_file2.puts("file\nanarchy\nNaNarchy")
	merge_file2.close

	merge_file3 = File.new('merger3', "w") #create a test file
	merge_file3.puts("or else")
	merge_file3.close


	assert_equal(diff_files(test_file1, test_file1), nil, "Self comparison faiure")

	assert_equal(diff_files(merge_file1, merge_file2), "first, NaNarchy", "Diff failure 1")

	assert_equal(diff_files(test_file1, merge_file1), "file, or else", "Diff failure 2")

	#########################################################
	# end diff_files 										#
	#########################################################

	#########
	# merge #
	#########

	#merge(fileA, fileB): returns a merged file or conflict file plus a new file id
	#merge("filenameA", "filenameB"): returns a merged file or conflict file plus a new file id

	#tests to make sure a file merged with
	#itself is unchanged, and that simple
	#and complex file merges work properly

	merge_file1 = File.new('merger1', "w") #create a test file
	merge_file1.puts("first\nfile\nanarchy")
	merge_file1.close

	merge_file2 = File.new('merger2', "w") #create a test file
	merge_file2.puts("file\nanarchy\nNaNarchy")
	merge_file2.close

	merge_file3 = File.new('merger3', "w") #create a test file
	merge_file3.puts("first\nfile\nanarchy\nNaNarchy")
	merge_file3.close

	merged = File.new('merged', "w") #create a test file
	merged.puts(">>merger1:1 first\nfile\n>>merger1:3 anarchy")
	merged.close


	assert_equal(merge(test_file1, test_file1)[0], test_file1, "Self comparison faiure")

	assert_equal(merge(merge_file1, merge_file2)[0], merge_file3, "Simple merge failure")

	assert_equal(merge(test_file1, merger1)[0], merged, "Complex merge failure")


	assert_raise do
		get_file(merge(test_file1, test_file1)[1]) #id is not yet used
	end

	assert_raise do
		get_file(merge(merge_file1, merge_file2)[1]) #id is not yet used
	end

	assert_raise do
		get_file((merge(test_file1, merger1)[1]) #id is not yet used
	end

	#########################################################
	# end merge 											#
	#########################################################
end
#########################################################
# end test												#
#########################################################





#Notes to self/implementation questions:

#Does add_file still need to return ids?
#What should repeated calls to `add_file("x")` do? Overwrite or create new instance?
#Should files have multiple instances saved or just one copy of each?
# => If instances, filenames do not suffice for passing files
#Should hash create unique ids for the same filename?

#Hash could return filename or file contents when given hashcode

#Should merge return a file id or simply store the file?
#Should merge delete the parameters files on exiting successfully?