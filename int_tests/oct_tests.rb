require 'fileutils'
require 'test/unit'

class IntegrationTests < Test::Unit::TestCase
	def command(command)
		system("cd test_dir && #{command}")
	end

	def setup
		system("mkdir test_dir")

		command("oct init")
		command("echo \"hello world\" > test")
		assert command("oct commit -m \"test\" test")
	end

	def teardown
		system("rm -r test_dir")
	end

	def test_second_commit
		command("echo \"hello world2\" > test2")
		assert command("oct commit -m \"test2\" test2")
	end

	def test_branching
		command("echo \"hello world2\" > test2")
		assert command("oct commit -m \"test2\" *")

		assert command("oct branch -a test_branch")

		command("echo \"hello world2\" > test3")
		assert command("oct commit -m \"test3\" *")

		assert command("oct checkout master")

		assert File.exist?("test1")
		assert File.exist?("test2")
		assert_false File.exist?("test3")
	end
end