require "test/unit"
require_relative "workspace"


class DVCS_test < Test::Unit::TestCase
	my_workspace = Workspace.new()

	def test_checkout_snapshot()
		flag = true
		workspace = '.octopus/'
		my_workspace = Workspace.new()
		my_workspace.check_out_snapshot(1)
		file_lst = ['test1.txt', 'test2.txt', 'text3.txt']
		file_lst.each do |f|
			flag = flag & File.exist?(workspace + f)
		end
		assert_equal(true, flag, 'Errors, not all files are copied to workspace!')
	end



	def test_clean()
		workspace = '.octopus/'
		my_workspace = Workspace.new()
		File.write(workspace + 'test.txt', '1')
		my_workspace.clean()
		flag = true
		flag = flag & File.exist?(workspace + 'test.txt')
		assert_equal(false, flag, 'Errors, files are not deleted!')
		file_lst = ['test1.txt', 'test2.txt', 'text3.txt']
		file_lst.each do |f|
			flag = flag & File.exist?(workspace + f)
		end
		assert_equal(true, flag, 'Errors, not all files are copied to workspace!')
	end



	def test_commit_nil()
		workspace = '.octopus/'
		my_workspace = Workspace.new()
		File.write(workspace + 'test1.txt', '1')
		File.write(workspace + 'test2.txt', '1')
		File.write(workspace + 'test3.txt', '1')
		file_hash = my_workspace.commit()
		answer = {".octopus/test2.txt"=>1, ".octopus/text3.txt"=>1, ".octopus/test1.txt"=>1}
		assert_equal(file_hash, answer, 'Errors, incorrect file hash table with nil parameter')	
	end


	def test_commit_files()
		workspace = '.octopus/'
		my_workspace = Workspace.new()
		File.write(workspace + 'test1.txt', '1')
		File.write(workspace + 'test2.txt', '1')
		file_hash = my_workspace.commit([workspace + 'test1.txt', workspace + 'test2.txt'])
		answer = {".octopus/test1.txt"=>1, ".octopus/test2.txt"=>1, ".octopus/Test1.txt"=>2, ".octopus/Test2.txt"=>3, ".octopus/Text3.txt"=>nil}
		assert_equal(file_hash, answer, 'Errors, incorrect file hash table with files')	
	end


	def test_commit_file()
		workspace = '.octopus/'
		my_workspace = Workspace.new()
		File.write(workspace + 'test1.txt', '1')
		file_hash = my_workspace.commit([workspace + 'test1.txt', workspace + 'test2.txt'])
		answer = {".octopus/test1.txt"=>1, ".octopus/Test1.txt"=>2, ".octopus/Test2.txt"=>3, ".octopus/Text3.txt"=>nil}
		assert_equal(file_hash, answer, 'Errors, incorrect file hash table with one single file')	
	end
end
