###############
# test public #
###############

#NOTE: diff() has been renamed to merge(), it's function is unchanged

def test_public()
	#########
	# store #
	#########

	#creates two files and stores them
	#fails if the hash id's returned are
	#invalid or the same

	test_file1 = File.new('test1.txt', "w") #create a test file
	test_file1.puts("file1")
	test_file1.close
	id1 = store(test_file1) #call store
	assert_equal(/(key structure)/,id1,"Invaid id 1") #make sure id is of the right form

	test_file2 = File.new('test2.txt', "w") #create a test file
	test_file2.puts("file2")
	test_file2.close
	id2 = store(test_file2) #call store
	assert_equal(/(key structure)/,id1,"Invaid id 2") #make sure id is of the right form
	assert_not_equal(id1,id2,"ID's were equal")

	#########################################################
	# end store												#
	#########################################################



	########
	# load #
	########

	#loads the two files previously stored
	#fails if retrieved files are not original files

	assert_equal(load(id1), test_file1, "Unexpected file loaded (file 1)")
	assert_equal(load(id2), test_file2, "Unexpected file loaded (file 2)")
	#########################################################
	# end load 												#
	#########################################################



	#########
	# merge #
	#########

	#tests to make sure a file diffed with
	#itself is unchanged, and that simple
	#and compex file merges work properly

	merge_file1 = File.new('merger1', "w") #create a test file
	merge_file1.puts("first\nfile\nanarchy")
	merge_file1.close

	merge_file2 = File.new('merger2', "w") #create a test file
	merge_file2.puts("file\nanarchy\nNaNarchy")
	merge_file2.close

	merge_file3 = File.new('merger3', "w") #create a test file
	merge_file3.puts("first\nfile\nanarchy\nNaNarchy")
	merge_file3.

	merged = File.new('merged', "w") #create a test file
	merged.puts("<<test1.txt:1	file1\n>>test2.txt:1 file2")
	merged.close


	assert_equal(merge(test_file1, test_file1), test_file1, "Self comparison faiure") 

	assert_equal(merge(merge_file1, merge_file2), merge_file3, "Simple merge failure") 

	assert_equal(merge(test_file1, test_file2), merged, "Complex merge failure") 

	#########################################################
	# end merge 											#
	#########################################################
end
#########################################################
# end test public 										#
#########################################################

################
# test private #
################
def test_private()
	########
	# hash #
	########

	#private hash function
	
	#fails if id is not of correct form
	#fails if ever generates the same key
	#even with same string

	id1 = hash("foo")
	id2 = hash("foo")
	id3 = hash("fool")

	assert_equal(/(key structure)/, id1, "Invaid hash id 1") #make sure id is of the right form
	assert_equal(/(key structure)/, id2, "Invaid hash id 2") #make sure id is of the right form
	assert_equal(/(key structure)/, id3, "Invaid hash id 3") #make sure id is of the right form
	assert_not_equal(id1, id2, "ID 1,2 were equal")
	assert_not_equal(id1, id3, "ID 1,3 were equal")
	assert_not_equal(id3, id2, "ID 2,3 were equal")

	#rigorous tests
	test_arr = []
	10000.times {test_arr.push(hash("foo"))}
	assert_equal(test_arr.detect{ |e| test_arr.count(e) > 1 }, nil, "Duplicate ID's (constant)")

	test_foo = []
	10000.times {|x| test_foo.push(hash("foo"+ x.to_s))}
	assert_equal(test_foo.detect{ |e| test_foo.count(e) > 1 }, nil, "Duplicate ID's (variant)")

	#########################################################
	# end hash												#
	#########################################################

end

#########################################################
# end test private 										#
#########################################################
