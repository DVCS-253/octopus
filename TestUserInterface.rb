#Includes 'UserInterface' class.
require_relative "UserInterface"

#Required for unit testing
require "test/unit"
 
#This class contains test cases for UserInterface class
class TestUserInterface < Test::Unit::TestCase

#Creating an object of UserInterface class
UI = UserInterface.new()


#List of commands to be tested.Note that I have used 'vcs' as the keyword just as 'git' in GitHub.

C_init = "vcs init"
C_add = "vcs add"
C_checkout = "vcs checkout"
C_commit = "vcs commit"
C_branch = "vcs branch"
C_merge = "vcs merge"
C_push = "vcs push"
C_pull = "vcs pull"
C_status = "vcs status"
C_clone = "vcs clone"
C_diff = "vcs diff"
C_help = "vcs help"
C_invalid_start = "abc commit"
C_invalid_command = "vcs pulled"
C_q = "q"
C_quit = "quit"
C_end = "end"
C_exit = "exit"

#List of messages that are shown for each command

Msg_init_success = "'init' executed!"
Msg_add_success = "'add' executed!"
Msg_checkout_success = "'checkout' executed!"
Msg_commit_success = "'commit' executed!"
Msg_branch_success = "'branch' executed!"
Msg_merge_success = "'merge' executed!"
Msg_push_success = "'push' executed!"
Msg_pull_success = "'pull' executed!"
Msg_status_success = "'status' executed!"
Msg_clone_success = "'clone' executed!"
Msg_diff_success = "'clone' executed!"
Msg_help_success = "'clone' executed!"

#List of error messages expected during the test

Msg_invalid_start = "Command should start with 'vcs'"
Msg_invalid_command = "Invalid command "

#List of valid tokens. Token is the array containing a command with its options, if any

C_init_tk = ["init"]
C_add_tk = ["add"]
C_checkout_tk = ["checkout"]
C_commit_tk = ["commit"]
C_branch_tk = ["branch"]
C_merge_tk = ["merge"]
C_push_tk = ["push"]
C_pull_tk = ["pull"]
C_status_tk = ["status"]
C_clone_tk = ["clone"]
C_diff_tk = ["diff"]
C_help_tk = ["help"]
C_invalid_command_tk = ["pulled"]

#Test cases

  def test_parseCommand
	  assert_equal(UI.parseCommand(C_init),UI.main(C_init))
	  assert_equal(UI.parseCommand(C_add),UI.main(C_add))
	  assert_equal(UI.parseCommand(C_checkout),UI.main(C_checkout))
	  assert_equal(UI.parseCommand(C_commit),UI.main(C_commit))
	  assert_equal(UI.parseCommand(C_branch),UI.main(C_branch))
	  assert_equal(UI.parseCommand(C_merge),UI.main(C_merge))
	  assert_equal(UI.parseCommand(C_push),UI.main(C_push))
	  assert_equal(UI.parseCommand(C_pull),UI.main(C_pull))
	  assert_equal(UI.parseCommand(C_status),UI.main(C_status))
	  assert_equal(UI.parseCommand(C_clone),UI.main(C_clone))
	  assert_equal(UI.parseCommand(C_diff),UI.main(C_diff))
	  assert_equal(UI.parseCommand(C_help),UI.main(C_help))
	  assert_equal(UI.parseCommand(C_invalid_start),UI.main(C_invalid_start))
	  assert_equal(UI.parseCommand(C_invalid_command),UI.main(C_invalid_command))
	  assert_raise(RuntimeError){ UI.main(C_q) }
	  assert_raise(RuntimeError){ UI.main(C_quit) }
	  assert_raise(RuntimeError){ UI.main(C_end) }
	  assert_raise(RuntimeError){ UI.main(C_exit) }
  end
  
  def test_executeCommand
      assert_equal(UI.executeCommand(C_init_tk),UI.main(C_init))
	  assert_equal(UI.executeCommand(C_add_tk),UI.main(C_add))
	  assert_equal(UI.executeCommand(C_checkout_tk),UI.main(C_checkout))
	  assert_equal(UI.executeCommand(C_commit_tk),UI.main(C_commit))
	  assert_equal(UI.executeCommand(C_branch_tk),UI.main(C_branch))
	  assert_equal(UI.executeCommand(C_merge_tk),UI.main(C_merge))
	  assert_equal(UI.executeCommand(C_push_tk),UI.main(C_push))
	  assert_equal(UI.executeCommand(C_pull_tk),UI.main(C_pull))
	  assert_equal(UI.executeCommand(C_status_tk),UI.main(C_status))
	  assert_equal(UI.executeCommand(C_clone_tk),UI.main(C_clone))
	  assert_equal(UI.executeCommand(C_diff_tk),UI.main(C_diff))
	  assert_equal(UI.executeCommand(C_help_tk),UI.main(C_help))
	  assert_equal(UI.executeCommand(C_invalid_command_tk),UI.main(C_invalid_command))
  end
  
  def test_displayResult
      assert_equal(UI.displayResult(Msg_init_success),UI.main(C_init))
	  assert_equal(UI.displayResult(Msg_add_success),UI.main(C_add))
	  assert_equal(UI.displayResult(Msg_checkout_success),UI.main(C_checkout))
	  assert_equal(UI.displayResult(Msg_commit_success),UI.main(C_commit))
	  assert_equal(UI.displayResult(Msg_branch_success),UI.main(C_branch))
	  assert_equal(UI.displayResult(Msg_merge_success),UI.main(C_merge))
	  assert_equal(UI.displayResult(Msg_push_success),UI.main(C_push))
	  assert_equal(UI.displayResult(Msg_pull_success),UI.main(C_pull))
	  assert_equal(UI.displayResult(Msg_status_success),UI.main(C_status))
	  assert_equal(UI.displayResult(Msg_clone_success),UI.main(C_clone))
	  assert_equal(UI.displayResult(Msg_status_diff),UI.main(C_diff))
	  assert_equal(UI.displayResult(Msg_clone_help),UI.main(C_help))
	  assert_equal(UI.displayResult(Msg_invalid_start),UI.main(C_invalid_start))
	  assert_match(UI.displayResult(Msg_invalid_command),UI.main(C_invalid_command))
  end

end