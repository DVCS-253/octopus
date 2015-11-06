#Includes 'UserInterface' class.
require_relative "UserInterface"

#Required for unit testing
require "test/unit"

#Contains the test cases for the supported commands
class TestUserInterface < Test::Unit::TestCase

#Instance of this class
UI = UserInterface.new()

#--Commands to be tested. 
#Valid Commands
InitCmd1 = ['init']
InitCmd2 = ['init', '"MyDirectory"']
AddCmd1 = ['add', '"file1"']
AddCmd2 = ['add', '"file2"']
AddCmd3 = ['add', '.']
CheckoutCmd1 = ['checkout']
CheckoutCmd2 = ['checkout', 'MyBranch']
CheckoutCmd3 = ['checkout', '-b', 'MyBranch']
CheckoutCmd4 = ['checkout', 'MyBranch', '--track', 'origin\master']
CommitCmd1a = ['commit']
CommitCmd2a = ['commit', '-m', '"added file"']
CommitCmd3a = ['commit', '-a', '-m', '"added file"']
CommitCmd4a = ['commit', '-m', '"added file"', 'file1']
CommitCmd5a = ['commit', '-m', '"added file"', 'file1', 'file2']
CommitCmd1b = ['commit']
CommitCmd2b = ['commit', '-m', 'added file']
CommitCmd3b = ['commit', '-a', '-m', 'added file']
CommitCmd4b = ['commit', '-m', 'added file', 'file1']
CommitCmd5b = ['commit', '-m', 'added file', 'file1', 'file2']
BranchCmd1 = ['branch', '-a']
BranchCmd2 = ['branch', '-d' 'MyBranch']
MergeCmd1 = ['merge', 'MyBranch']
PushCmd1 = ['push', 'origin', 'master']
PullCmd1 = ['pull', 'origin', 'master']
StatusCmd1 = ['status']
CloneCmd1 = ['clone', 'MyRepo']
CloneCmd2 = ['clone', 'MyRepo', '"MyDirectory"']
DiffCmd1 = ['diff', 'MyBranch', 'YourBranch']
HelpCmd1 = ['help']

#--Invalid Commands
InitCmdInv = ['init', 'My', 'Directory']
AddCmdInv = ['add', 'My' 'File']
CheckoutCmdInv = ['checkout', 'My', 'Branch']
CommitCmdInv = ['commit', 'My', 'Files']
BranchCmdInv = ['branch', 'My', 'Directory']
MergeCmdInv = ['merge', 'Your', 'Directory']
PushCmdInv = ['push', 'My', 'Repo']
PullCmdInv = ['pull', 'My' 'Repo']
StatusCmdInv = ['status', 'My', 'Workspace']
CloneCmdInv = ['clone', 'My', 'Repo']
DiffCmdInv = ['diff', 'My', 'Branch', 'and', 'Your', 'Branch']
HelpCmdInv = ['help', 'Me']

#Test cases

  #Test for 'init' command and its parameters
  def test_init
  	assert_equal(UI.parseCommand('init', InitCmd1*" "),UI.main(InitCmd1))
  	assert_equal(UI.parseCommand('init', InitCmd2*" "),UI.main(InitCmd2))
  	assert_equal(UI.parseCommand('init', InitCmdInv*" "),UI.main(InitCmdInv))
  end
  
  #Test for 'add' command and its parameters
  def test_add
  	assert_equal(UI.parseCommand('add', AddCmd1*" "),UI.main(AddCmd1))
  	assert_equal(UI.parseCommand('add', AddCmd2*" "),UI.main(AddCmd2))
  	assert_equal(UI.parseCommand('add', AddCmd3*" "),UI.main(AddCmd3))
  	assert_equal(UI.parseCommand('add', AddCmdInv*" "),UI.main(AddCmdInv))
  end
  
  #Test for 'checkout' command and its parameters
  def test_checkout
  	assert_equal(UI.parseCommand('checkout', CheckoutCmd1*" "),UI.main(CheckoutCmd1))
  	assert_equal(UI.parseCommand('checkout', CheckoutCmd2*" "),UI.main(CheckoutCmd2))
  	assert_equal(UI.parseCommand('checkout', CheckoutCmd3*" "),UI.main(CheckoutCmd3))
  	assert_equal(UI.parseCommand('checkout', CheckoutCmd4*" "),UI.main(CheckoutCmd4))
  	assert_equal(UI.parseCommand('checkout', CheckoutCmdInv*" "),UI.main(CheckoutCmdInv))
  end
  
  #Test for 'commit' command and its parameters
  def test_commit
  	assert_equal(UI.parseCommand('commit', CommitCmd1a*" "),UI.main(CommitCmd1b))
  	assert_equal(UI.parseCommand('commit', CommitCmd2a*" "),UI.main(CommitCmd2b))
  	assert_equal(UI.parseCommand('commit', CommitCmd3a*" "),UI.main(CommitCmd3b))
  	assert_equal(UI.parseCommand('commit', CommitCmd4a*" "),UI.main(CommitCmd4b))
  	assert_equal(UI.parseCommand('commit', CommitCmd5a*" "),UI.main(CommitCmd5b))
  	assert_equal(UI.parseCommand('commit', CommitCmdInv*" "),UI.main(CommitCmdInv))
  end
  
  #Test for 'branch' command and its parameters
  def test_branch
  	assert_equal(UI.parseCommand('branch', BranchCmd1*" "),UI.main(BranchCmd1))
  	assert_equal(UI.parseCommand('branch', BranchCmd2*" "),UI.main(BranchCmd2))
  	assert_equal(UI.parseCommand('branch', BranchCmdInv*" "),UI.main(BranchCmdInv))
  end
  
  #Test for 'merge' command and its parameters
  def test_merge
  	assert_equal(UI.parseCommand('merge', MergeCmd1*" "),UI.main(MergeCmd1))
  	assert_equal(UI.parseCommand('merge', MergeCmdInv*" "),UI.main(MergeCmdInv))
  end
  
  #Test for 'push' command and its parameters
  def test_push
  	assert_equal(UI.parseCommand('push', PushCmd1*" "),UI.main(PushCmd1))
  	assert_equal(UI.parseCommand('push', PushCmdInv*" "),UI.main(PushCmdInv))
  end
  
  #Test for 'pull' command and its parameters
  def test_pull
  	assert_equal(UI.parseCommand('pull', PullCmd1*" "),UI.main(PullCmd1))
  	assert_equal(UI.parseCommand('pull', PullCmdInv*" "),UI.main(PullCmdInv))
  end
  
  #Test for 'status' command and its parameters
  def test_status
  	assert_equal(UI.parseCommand('status', StatusCmd1*" "),UI.main(StatusCmd1))
  	assert_equal(UI.parseCommand('status', StatusCmdInv*" "),UI.main(StatusCmdInv))
  end
  
  #Test for 'clone' command and its parameters
  def test_clone
  	assert_equal(UI.parseCommand('clone', CloneCmd1*" "),UI.main(CloneCmd1))
  	assert_equal(UI.parseCommand('clone', CloneCmd2*" "),UI.main(CloneCmd2))
  	assert_equal(UI.parseCommand('clone', CloneCmdInv*" "),UI.main(CloneCmdInv))
  end
  
  #Test for 'diff' command and its parameters
  def test_diff
  	assert_equal(UI.parseCommand('diff', DiffCmd1*" "),UI.main(DiffCmd1))
  	assert_equal(UI.parseCommand('diff', DiffCmdInv*" "),UI.main(DiffCmdInv))
  end
  
  #Test for 'help' command and its parameters
  def test_help
  	assert_equal(UI.parseCommand('help', HelpCmd1*" "),UI.main(HelpCmd1))
  	assert_equal(UI.parseCommand('help', HelpCmdInv*" "),UI.main(HelpCmdInv))
  end
  
end