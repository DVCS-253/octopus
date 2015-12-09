require 'fileutils'
require 'test/unit'

class IntegrationTests < Test::Unit::TestCase
	def command(command)
		system("cd test_dir && #{command}")
	end

	def file_exists(file)
		File.exist?("test_dir/#{file}")
	end

	def file_contents(file)
		File.read("test_dir/#{file}").to_s.strip
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

	def nottest_second_commit
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

		assert file_exists("test")
		assert file_exists("test2")
		assert_false file_exists("test3")

		assert command("oct checkout test_branch")

		assert file_exists("test")
		assert file_exists("test2")
		assert file_exists("test3")

		# Try committing on new branch

		command("echo \"hello world2\" > test4")
		command("echo \"from branch\" > test")
		assert command("oct commit -m \"test4\" *")

		assert command("oct checkout master")

		assert file_exists("test")
		assert_equal file_contents("test"), "hello world"
		assert file_exists("test2")
		assert_false file_exists("test3")

		assert command("oct checkout test_branch")
		assert file_exists("test")
		assert_equal file_contents("test"), "from branch"
		assert file_exists("test2")
		assert file_exists("test3")
		assert file_exists("test4")

		# Third branch

		assert command("oct branch -a test_branch2")

		command("echo \"from branch2\" > test")
		command("echo \"hello world 5\" > test5")
		assert command("oct commit -m \"test\" *")

		assert command("oct checkout test_branch")
		assert_equal file_contents("test"), "from branch"
		assert_false file_exists("test5")

		assert command("oct checkout master")
		assert_equal file_contents("test"), "hello world"
		assert_false file_exists("test5")

		assert command("oct checkout test_branch2")
		assert_equal file_contents("test"), "from branch2"
		assert file_exists("test5")
	end

	def nottest_cloned_branching
		system("rm -r test_dir")
		system("oct clone ashanina@cycle1.csug.rochester.edu:/u/ashanina/Documents/253/octopus/int_tests/test_dir")

		assert file_exists("test")
		assert file_exists("test2")
		assert_false file_exists("test3")
		assert_false file_exists("test4")
		assert_false file_exists("test5")
		assert_equal file_contents("test"), "hello world"

		assert command("oct checkout test_branch")

		assert file_exists("test")
		assert file_exists("test2")
		assert file_exists("test3")
		assert file_exists("test4")
		assert_false file_exists("test5")
		assert_equal file_contents("test"), "from branch"

		assert command("oct checkout test_branch2")

		assert file_exists("test")
		assert file_exists("test2")
		assert file_exists("test3")
		assert file_exists("test4")
		assert file_exists("test5")
		assert_equal file_contents("test"), "from branch2"
	end

	def nottest_push
		remote = "ashanina@cycle1.csug.rochester.edu:/u/ashanina/Documents/253/octopus/int_tests/test_dir"

		system("rm -r test_dir")
		system("oct clone #{remote}")

		command("oct checkout test")

		command("oct status")

		command("echo \"push test\" > push4file")
		assert command("oct commit -m \"pushing 1 commit\" *")

		assert command("oct push #{remote} test")

		# assert command("oct checkout push1")

		# command("echo \"push test\" > push1file")
		# assert command("oct commit -m \"pushing 1 commit\" *")

		# assert command("oct push #{remote} push1")
	end
end