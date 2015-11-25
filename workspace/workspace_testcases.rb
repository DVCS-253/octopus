require "test/unit"
require_relative "workspace_testversion"


class DVCS_test < Test::Unit::TestCase
	my_workspace = Workspace.new()


	def test_init
		my_workspace = Workspace.new()
		my_workspace.init
		my_workspace.clean
		assert_equal(true, File.directory?())
		assert_equal(true, File.exist?())
		assert_equal(true, File.exist?())
		assert_equal(true, File.exist?())
	end



	def test_rebuild_dir
		path = 'Test/test.rb'
		my_workspace = Workspace.new()
		my_workspace.init
		my_workspace.clean
		my_workspace.rebuild_dir(path)
		assert_equal(true, File.directory?('./Test'))
		assert_equal(false, File.exist?('./Test/test.rb'))
	end


	def test_clean
		my_workspace = Workspace.new()
		my_workspace.init
		File.write('test,rb', 'test_content')
		assert_equal(false, File.exist?('test.rb'))
		assert_equal(true, File.directory?())
		assert_equal(true, File.exist?())
		assert_equal(true, File.exist?())
		assert_equal(true, File.exist?())
		
	end


	def test_checkout_snapshot
		flag = true
		my_workspace = Workspace.new()
		my_workspace.init
		my_workspace.clean
		my_workspace.check_out_snapshot(1)
		file_lst = ['test1.txt', 'test2.txt', 'text3.txt']
		file_lst.each do |f|
			flag = flag & File.exist?(f)
		end
		assert_equal(true, flag, 'Errors, not all files are copied to workspace!')
	end



	def test_checkout_file
		my_workspace = Workspace.new()
		my_workspace.init
		my_workspace.clean
		my_workspace.check_out_file(1)
		file_name = 'test1.txt'
		flag = File.exist?(file_name)
		assert_equal(true, flag, 'Errors, not all files are copied to workspace!')
	end



	def test_checkout
		test_checkout_file
		test_checkout_snapshot
	end

	
	def test_build_hash
		my_workspace = Workspace.new()
		my_workspace.init
		my_workspace.clean
		File.write('test1.rb', '1')
		File.write('test2.rb', '2')
		File.write('tset3.rb', '3')
		file_lst = ['test1.txt', 'test2.txt', 'text3.txt']
		hash = my_workspace.build_hash(file_lst)
		corret = {"test2.txt"=>'1', "text2.txt"=>2, "test3.txt"=>3}
		assert_equal(corret, hash)
	

	
	def test_commit_nil()
		my_workspace = Workspace.new()
		my_workspace.init
		my_workspace.clean
		File.write('test1.txt', '1')
		File.write('test2.txt', '1')
		File.write('test3.txt', '1')
		file_hash = my_workspace.commit(commit_msg = 'test')
		answer = {"test2.txt"=>1, "text3.txt"=>1, "test1.txt"=>1}
		assert_equal(file_hash, answer, 'Errors, incorrect file hash table with nil parameter')	
	end



	def test_commit_files()
		my_workspace = Workspace.new()
		my_workspace.init
		my_workspace.clean
		File.write('test1.txt', '1')
		File.write('test2.txt', '1')
		file_hash = my_workspace.commit(['test1.txt', 'test2.txt'], commit_msg = 'test')
		answer = {"test1.txt"=>'1', "test2.txt"=>'1'}
		assert_equal(file_hash, answer, 'Errors, incorrect file hash table with files')	
	end


	def test_commit_files()
		my_workspace = Workspace.new
		my_workspace.init
		my_workspace.clean
		File.write('test1.txt', '1')
		File.write('test2.txt', '2')
		File.write('test3.txt', '3')
		correct = ['test3.txt']
		uncommitted = my_workspace.status
		assert_equal(uncommitted, correct)	

end
