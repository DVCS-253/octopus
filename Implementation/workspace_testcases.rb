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
		my_workspace.init()
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
		my_workspace.init()
		File.write(workspace + 'test1.txt', '1')
		File.write(workspace + 'test2.txt', '1')
		file_hash = my_workspace.commit([workspace + 'test1.txt', workspace + 'test2.txt'])
		answer = {".octopus/test1.txt"=>1, ".octopus/test2.txt"=>1, ".octopus/Test1.txt"=>2, ".octopus/Test2.txt"=>3, ".octopus/Text3.txt"=>nil}
		assert_equal(file_hash, answer, 'Errors, incorrect file hash table with files')	
	end



	def test_commit_file()
		workspace = '.octopus/'
		my_workspace = Workspace.new()
		my_workspace.init()
		File.write(workspace + 'test1.txt', '1')
		file_hash = my_workspace.commit([workspace + 'test1.txt', workspace + 'test2.txt'])
		answer = {".octopus/test1.txt"=>1, ".octopus/Test1.txt"=>2, ".octopus/Test2.txt"=>3, ".octopus/Text3.txt"=>nil}
		assert_equal(file_hash, answer, 'Errors, incorrect file hash table with one single file')	
	end



	def test_status()
		workspace = '.octopus/'
		my_workspace = Workspace.new()
		my_workspace.init()
		my_workspace.check_out_snapshot(1)
		add, delete, update, rename = my_workspace.status()
		assert_equal(add, [".octopus/test3.txt"], 'Errors, new added file list is incorrect.')
		assert_equal(delete, [".octopus/Test1.txt"], 'Errors, deleted file list is incorrect.')
		assert_equal(update, [".octopus/test2.txt"], 'Errors, updated files list is incorrect.')
		assert_equal(rename,  [".octopus/Test3.txt => .octopus/test1.txt"], 'Errors, renamed file list is incorrect.')
	end


	def test_share_value()
		my_workspace = Workspace.new()
		test_hash = {'one' => 1, 'two' => 2, 'three' => 3}
		answer = my_workspace.share_value(test_hash, 1)
		assert_equal(answer, 'one')
		answer = my_workspace.share_value(test_hash, 4)
		assert_equal(answer, false)
	end
end
