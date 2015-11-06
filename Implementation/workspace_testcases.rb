require "test/unit"
require "workspace"

class DVCS_test < Test::Unit::TestCase
	my_workspace = Workspace.new()


	#prepare the workspace for testing
	#step 1: clean the workspace directory
	#step 2: create "staged_folder" folder for staged files as well as ".commit_history" for commit log
	#step 3: create a folder called "Test" for testing directory operations then create a file "test1" in this folder
	#step 4: create a file named as "test2" for testing file operations 
	#step 5: create a file named as "test3" in "staged_folder" as a staged file

	def prepare(path)		
		FileUtils.rm_rf(fullname)					#clean everything first
		FileUtils.mkdir_p(path + 'staged_folder')			#staged file directory
		out_file = File.new(path + '.commit_history', "w")		#commit log
		out_file.close()
		FileUtils.mkdir_p(path + 'Test')
		out_file = File.new(path + 'Test/' + 'test1', "w")		#unstaged file, in a sub-directory in workspace
		out_file.puts("create a new file.")
		out_file.close
		out_file = File.new(path + 'test2', "w")			#unstaged file, in workspace
		out_file.puts("create a new file.")
		out_file.close
		out_file = File.new(path + 'staged_folder/test3', "w")	#staged file, in staged_folder
		out_file.puts("create a new file.")
		out_file.close
	end



	#test clean function
	#step 1: call prepare function to set up the workspace
	#step 2: call clean function
	#step 3: test directory operations by checking if "Test" directory exists
	#step 4: test file operations by checking if "test2" exists
	#step 5: test if staged files are safe by checking if "staged_folder/test3" exists

	def test_clean()	
		path = '/u/thu/CD class/Implement_test_case/test/'#path: path of workspace
		prepare(path) 
		my_workspace.clean()#call the function		
		directory_exist = File.directory?(path + 'Test/')
		assert_equal(false, directory_exist, 'Errors, delete directory failed!')
		file_exist = File.directory?(path + 'test2')
		assert_equal(true, file_exist, 'Errors, unstagd files are not deleted!')
		file_exist = File.directory?(path + 'staged_folder/test3')
		assert_equal(true, file_exist, 'Errors, stagd files are deleted!')
	end




	#test commit
	#step 1: test commit()
	#step 1.1: prepare the workspace
	#step 1.2: call commit() to commit the whole workspace
	#step 1.3: test if the directory is copied to staged_folder
	#step 1.4: test if the files in the directory is copied to the right place
	#step 1.5: test if the files in workspace is copied to staged_folder
	#step 1.6: test if the the .commit_history is generated properly by comparing it with a pre-generated file	
	#step 2: test commit(directory)
	#step 2.1: prepare the workspace
	#step 2.2: call commit(directory) to commit a directory
	#step 2.3: test if the directory is copied to staged_folder
	#step 2.4: test if the files in the directory is copied to the right place  
	#step 2.5: test if the the .commit_history is generated properly by comparing it with a pre-generated file
	#step 3: test commit(file)
	#step 3.1: prepare the workspace
	#step 3.2: call commit(file) to commit a file
	#step 3.3: test is the file is copied to the right place
	#step 3.4: test if the the .commit_history is generated properly by comparing it with a pre-generated file
	def test_commit()
		path = '/u/thu/CD class/Implement_test_case/test/'           				#path: path of workspace
		###test commit()
		prepare(path)
		my_workspace.commit()
		#test if the directory is copied
		assert_equal(true, File.directory?(path + 'staged_folder/Test', 'Errors. Folder not committed')
		#test if the file in the directory is copied
		assert_equal(true, File.exist?(path + 'staged_folder/Test/test1', 'Errors. File is not generated in staged_file folder')
		#test if the file is copied
		assert_equal(true, File.exist?(path + 'staged_folder/test2', 'Errors. File is not generated in staged_file folder')
		#test if the .commit_history is generated properly
		indentical = FileUtils.compare_file('commit_history1', path + '.commit_history') 
		assert_equal(true, identical, 'Errors. commit_histroy log is not generated properly')
		###test commit(folder)
		prepare(path)
		my_workspace.commit("Test")
		#test if the directory is copied
		assert_equal(true, File.directory?(path + 'staged_folder/Test', 'Errors. Folder not committed')
		#test if the file in the directory is copied
		assert_equal(true, File.exist?(path + 'staged_folder/Test/test1', 'Errors. File is not generated in staged_file folder')
		#test if the .commit_history is generated properly
		indentical = FileUtils.compare_file('commit_history2', path + '.commit_history') 
		assert_equal(true, identical, 'Errors. commit_histroy log is not generated properly')
		#test commit(file)
		prepare(path)
		my_workspace.commit("test2")
		#test if the file is copied
		assert_equal(true, File.exist?(path + 'staged_folder/test2', 'Errors. File is not generated in staged_file folder')
		#test if the .commit_history is generated properly
		indentical = FileUtils.compare_file('commit_history3', path + '.commit_history') 
		assert_equal(true, identical, 'Errors. commit_histroy log is not generated properly')

	end

end
