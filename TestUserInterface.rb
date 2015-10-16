require_relative "UserInterface"

require "test/unit"
 
class TestUserInterface < Test::Unit::TestCase

UI = UserInterface.new()

C_init = "vcs init"
C_add = "vcs add"
C_checkout = "vcs checkout"
C_commit = "vcs commit"
C_branch = "vcs branch"
C_merge = "vcs merge"
C_push = "vcs push"
C_pull = "vcs pull"
C_status = "vcs status"

Msg_init_success = "'init' executed!"
Msg_add_success = "'add' executed!"
Msg_checkout_success = "'checkout' executed!"
Msg_commit_success = "'commit' executed!"
Msg_branch_success = "'branch' executed!"
Msg_merge_success = "'merge' executed!"
Msg_push_success = "'push' executed!"
Msg_pull_success = "'pull' executed!"
Msg_status_success = "'status' executed!"

Msg_invalid_start = "Command should start with 'vcs'"
Msg_invalid_command = "Invalid command "

C_init_tk = ["init"]
C_add_tk = ["add"]
C_checkout_tk = ["checkout"]
C_commit_tk = ["commit"]
C_branch_tk = ["branch"]
C_merge_tk = ["merge"]
C_push_tk = ["push"]
C_pull_tk = ["pull"]
C_status_tk = ["status"]

C_invalid_start = "abc commit"
C_invalid_command = "vcs pulled"
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
	  assert_equal(UI.parseCommand(C_invalid_start),UI.main(C_invalid_start))
	  assert_equal(UI.parseCommand(C_invalid_command),UI.main(C_invalid_command))
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
	  assert_equal(UI.displayResult(Msg_invalid_start),UI.main(C_invalid_start))
	  assert_match(UI.displayResult(Msg_invalid_command),UI.main(C_invalid_command))
    
  end

end