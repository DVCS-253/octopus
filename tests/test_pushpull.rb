require 'fileutils'
require 'test/unit'

# Tests public methods of the push/pull module.
#
# Assumptions:
#   - There is a method call to initialize an empty repository.
#   - There is a method to stage a file.
#   - There is a method to commit with a message.
#   - There is a method to obtain the commit log.
#   - There is a method to obtain a list of staged files.
#
class TestPushPull < Test::Unit::TestCase

  # Defines testing variables before each test runs.
  # A local and remote test repository are set up at
  # @base_dir+@local_dir and @base_dir+@remote_dir.
  #
  def setup
    @base_dir   = Dir.getwd + '/'
    @local_dir  = 'repo_1/'
    @remote_dir = 'repo_2/'
    @clone_dir  = 'repo_clone/'

    @files = [
      'a.txt',
      'b.txt'
    ]

    @local_file_contents = [
      'apple\nalgorithm\nAPI\nAPL',
      'binary\nbit\nbyte'
    ]

    @local_commit_messages = [
      'Added "API" to A words',
      'Added "bit" to B words'
    ]

    @remote_file_contents = [
      'apple\nalgorithm\nAPL',
      'binary\nbyte'
    ]

    @remote_commit_messages = [
      'Added A words',
      'Added B words'
    ]

    # Initialize a local and remote repository
    Dir.mkdir(@local_dir, 0755)
    Dir.mkdir(@remote_dir, 0755)
    init(@local_dir)
    init(@remote_dir)
  end

  # Cleans up the test repositories after each test.
  #
  def teardown
    # Clean up
    Dir.chdir(@base_dir)
    FileUtils.rm_rf(@local_dir)
    FileUtils.rm_rf(@remote_dir)
  end



  # Tests connecting to a machine.
  #
  def test_connect
    # Assert that the machine can be connected to
    assert(connect('127.0.0.1'+@base_dir+@remote_dir),
           'Failed to connect to remote machine.')
  end


  # Tests pulling from a remote repo to an empty local repo.
  # This test asserts that commit history and staged files are preserved.
  #
  def test_pull_into_empty_repo
    # Create a commit history on the remote
    Dir.chdir(@base_dir+@remote_dir)
    File.write(@files[0], @remote_file_contents[0])
    stage(@files[0])
    commit(@remote_commit_messages[0])

    # Change to the local repository and pull
    Dir.chdir(@base_dir+@local_dir)
    pull('127.0.0.1'+@base_dir+@remote_dir)

    # Assert that the commit history and staged files are correct
    assert_equal(@remote_commit_messages[0], get_last_commit_message(),
                 'Commit history was not preserved when pulling from remote.')
    assert_equal([@files[0]], get_staged_files(),
                 'List of staged files was not preserved when pulling from remote.')
    assert_equal(@remote_file_contents[0], File.read(@files[0]),
                 'File contents were not preserved when pulling from remote.')
  end

  # Tests pulling from a remote repo to a local repo with committed changes.
  # This test asserts that commit history and staged files are preserved.
  #
  def test_pull_into_committed_repo
    # Create a commit history locally for file 1
    Dir.chdir(@base_dir+@local_dir)
    File.write(@files[0], @local_file_contents[0])
    stage(@files[0])
    commit(@local_commit_messages[0])

    # Pull from local and create a commit history on the remote for file 1 and 2
    Dir.chdir(@base_dir+@remote_dir)
    pull('127.0.0.1'+@base_dir+@local_dir)

    File.write(@files[0], @remote_file_contents[0])
    stage(@files[0])
    commit(@remote_commit_messages[0])

    File.write(@files[1], @remote_file_contents[1])
    stage(@files[1])
    commit(@remote_commit_messages[1])

    # Change to the local repository and pull
    Dir.chdir(@base_dir+@local_dir)
    pull('127.0.0.1'+@base_dir+@remote_dir)

    # Assert that the commit history and staged files are correct
    assert_equal(@remote_commit_messages[0], get_second_to_last_commit_message(),
                 'Commit history was not preserved when pulling from remote.')
    assert_equal(@remote_commit_messages[1], get_last_commit_message(),
                 'Commit history was not preserved when pulling from remote.')
    assert_equal([@files[0], @files[1]], get_staged_files(),
                 'List of staged files was not preserved when pulling from remote.')
    assert_equal(@remote_file_contents[0], File.read(@files[0]),
                 'File contents were not merged when pulling from remote.')
    assert_equal(@remote_file_contents[1], File.read(@files[1]),
                 'File contents were not preserved when pulling from remote.')
  end
  
  # Tests pulling from a remote repo to a local repo with uncommitted changes.
  # This test asserts that an exception is raised.
  #
  def test_pull_into_uncommitted_repo
    # Create uncommitted changes locally for file 1
    Dir.chdir(@base_dir+@local_dir)
    File.write(@files[0], @local_file_contents[0])

    # Create a commit history on the remote for file 1
    Dir.chdir(@base_dir+@remote_dir)
    File.write(@files[0], @remote_file_contents[0])
    stage(@files[0])
    commit(@remote_commit_messages[0])

    # Assert that pulling raises an exception
    Dir.chdir(@base_dir+@local_dir)
    assert_raise do
      pull('127.0.0.1'+@base_dir+@remote_dir)
    end
  end


  # Tests cloning a remote repo into a new directory.
  # This test asserts that commit history and staged files are preserved.
  #
  def test_clone
    # Create a commit history on the remote
    Dir.chdir(@base_dir+@remote_dir)
    File.write(@files[0], @remote_file_contents[0])
    stage(@files[0])
    commit(@remote_commit_messages[0])

    # Clone the remote repo into a new folder called @clone_dir
    clone('127.0.0.1'+@base_dir+@remote_dir, @clone_dir)
    Dir.chdir(@base_dir+@clone_dir)

    # Assert that the commit history and staged files are correct
    assert_equal(@remote_commit_messages[0], get_last_commit_message(),
                 'Commit history was not preserved when cloning remote.')
    assert_equal([@files[0]], get_staged_files(),
                 'List of staged files was not preserved when cloning remote.')
    assert_equal(@remote_file_contents[0], File.read(@files[0]),
                 'File contents were not preserved when cloning remote.')
  end


  # Tests pushing to an empty remote repo from a local repo.
  # This test asserts that commit history and staged files are preserved.
  #
  def test_push_to_empty_repo
    # Create a commit history locally
    Dir.chdir(@local_dir)
    File.write(@files[0], @local_file_contents[0])
    stage(@files[0])
    commit(@local_commit_messages[0])

    # Push to the remote
    push('127.0.0.1'+@base_dir+@remote_dir)

    # Assert that the commit history and staged files are correct
    Dir.chdir(@base_dir+@remote_dir)
    assert_equal(@local_commit_messages[0], get_last_commit_message(),
                 'Commit history was not preserved when pushing to remote.')
    assert_equal([@files[0]], get_staged_files(),
                 'List of staged files was not preserved when pushing to remote.')
    assert_equal(@local_file_contents[0], File.read(@files[0]),
                 'File contents were not preserved when pushing to remote.')
  end

  # Tests pushing to a remote repo with committed changes from a local repo.
  # This test asserts that commit history and staged files are preserved.
  #
  def test_push_to_committed_repo
    # Create a commit history on the remote
    Dir.chdir(@base_dir+@remote_dir)
    File.write(@files[0], @remote_file_contents[0])
    stage(@files[0])
    commit(@remote_commit_messages[0])

    # Create a commit history locally
    Dir.chdir(@base_dir+@local_dir)
    pull('127.0.0.1'+@base_dir+@remote_dir)

    File.write(@files[0], @local_file_contents[0])
    stage(@files[0])
    commit(@local_commit_messages[0])

    File.write(@files[1], @local_file_contents[1])
    stage(@files[1])
    commit(@local_commit_messages[1])

    # Push to the remote
    push('127.0.0.1'+@base_dir+@remote_dir)

    # Assert that the commit history and staged files are correct
    Dir.chdir(@base_dir+@remote_dir)
    assert_equal(@local_commit_messages[0], get_second_to_last_commit_message(),
                 'Commit history was not preserved when pushing to remote.')
    assert_equal(@local_commit_messages[1], get_last_commit_message(),
                 'Commit history was not preserved when pushing to remote.')
    assert_equal([@files[0], @files[1]], get_staged_files(),
                 'List of staged files was not preserved when pushing to remote.')
    assert_equal(@local_file_contents[0], File.read(@files[0]),
                 'File contents were not merged when pushing to remote.')
    assert_equal(@local_file_contents[1], File.read(@files[1]),
                 'File contents were not preserved when pushing to remote.')
  end

  # Tests pushing to a remote repo with uncommitted changes from a local repo.
  # This test asserts that an exception is raised.
  #
  def test_push_to_uncommitted_repo
    # Create uncommitted changes on the remote
    Dir.chdir(@base_dir+@remote_dir)
    File.write(@files[0], @remote_file_contents[0])

    # Create a commit history locally
    Dir.chdir(@base_dir+@local_dir)
    pull('127.0.0.1'+@base_dir+@remote_dir)
    File.write(@files[0], @local_file_contents[0])
    stage(@files[0])
    commit(@local_commit_messages[0])

    # Assert that pushing raises an exception
    Dir.chdir(@base_dir+@local_dir)
    assert_raise do
      push('127.0.0.1'+@base_dir+@remote_dir)
    end
  end

end
