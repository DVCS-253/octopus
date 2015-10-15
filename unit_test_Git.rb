require "test/unit"

class Enumerate_Test < Test::Unit::TestCase
	def test_simple
		
	end
end

#test clean_work_space
#input: path of workspace
#1, create a new file in workspace (in case the workspace was empty)
#2, call the clean_work_space 
#3, test if the work space is empty
#4, call the clean_work_space to test if it's functional when the workspace is empty
#5, test if the work sapce is still empty

def test_clean_work_space(path)			#path: path of workspace
	out_file = File.new(path + 'test', "w") # create a text file in workspace
	out_file.puts("create a new file.")
	out_file.close		 
	clean_work_space			#call the function
	empty = Dir[path].empty?
	assert_equal(true, empty, 'Errors when cleaning up workspace.')
	clean_work_space
	empty = Dir[path].empty?
	assert_equal(true, empty, 'Errors occur when the workspace is originally empty')
end


#test generate_staged_folder
#input: path of workspace
#1, call generate_staged_folder
#2, test if staged_folder exist
#3, test if new generated staged_folder is empty

def test_generate_staged_folder(path)
	generate_staged_folder
	folder_exist = File.directory?(path + 'staged_folder')
	assert_equal(true, folder_exist, 'Errors. staged_folder is not generated')
	empty = Dir[path + 'staged_folder'].empty?
	assert_equal(true, empty, 'Errors. Generated staged_folder is not eampty')
end




#test transfer_files
#input: 1, path of workspace; 2, version no.
#1, Using some function in Repos module to get the file list of this version
#2, Call transfer_file function to transfer all the file into workspace
#3, For each file in the file list, test if the file in the workspace or not

def test_transfer_files(path, version_no)	
	file_lst = Repos_function(version_no)	#call function in Repos to get the list of files in the version
	transfer_files(version_no)
	flag = true
	for each in file_lst:			#check if every file in the list is in workspace
		flag  = flag && File.exist?(path + each)
	end
	assert_equal(true, flag, 'Errors. File is missing')
end


#test version_info
#input: 1, workspace path; 2, version no; 3, file list that should be listed in the version_info.dat; 4, a file contains the "right anwser"
#1, delet version_info.dat if it exists
#2, call version_info function
#3, test if version_info.dat is generated
#4, test if the content of version_info.dat is right by testing if generated version_info.dat is indentical to the given right one 

def test_version_info(version_no, file_list, test_file_path, path)
	if File.exist?(path + 'version_info.dat')
		File.delete(path + 'version_info.dat')
	end
	version_info(version_no, file_list) 	#call version_info to generate version_info.dat
	assert_equal(true, File.exist?(path + 'version_info.dat', 'Errors, didnt generate version_info.dat')
	identical = FileUtils.compare_file(test_file_path, 'version_info.dat')  
	assert_equal(true, identical, 'Errors, the generated version_info.dat is incorrect')
end



#test return_commit_file_list
#input: 1, workspace path; 2, a file contains the "right answer" to test the correctness of generted file
#1, delete file_state.dat if it exists
#2, call return_commit_file_list
#3, test if the file_state.dat exist
#4, test if the content of file.state.dat is right
def test_return_commit_file_list(test_file_path, path)
	if File.exist?(path + 'file_state.dat')
		File.delete(path + 'file_state.dat')
	end
	return_commit_file_list			#call the function to return the list of files 
	assert_equal(true, File.exist?(path + 'file_state.dat', 'Errors, didnt generate file_state.dat')
	indentical = FileUtils.compare_file(test_file_path, 'file_state.dat')
	assert_equal(true, identical, 'Errors, the generated version_info.dat is incorrect') 
end




#test check_out_workspace
#input: 1, workspace path; 2, version no. 3, 
#1, test clean_work_space
#2, test generate_staged_folder
#3, test version_info
def test_check_out_work_space(version_no, test_version_file)
	test_transfer_files
	test_version_info
end


#test stage
#input: 1, filename of the staged file; 2, path of workspace
#1, call stage, a copy of the staged file should be stored in staged_file folder
#2, test if there is a file with same name exist it staged_file folder
#3, test if this file in staged_file folder is the same with the file staged
def test_stage(file_name, path)
	stage(file_name)
	assert_equal(true, File.exist?(path + 'staged_folder/' + file_name, 'Errors. File is not generated in staged_file folder')
	indentical = FileUtils.compare_file(path + file_name, path + 'staged_folder/' + file_name) 
	assert_equal(true, identical, 'Errors. File is not copied into staged_folder corretly')
end

	
