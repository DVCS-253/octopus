require 'fileutils'
require 'test/unit'

class TestPushPull < Test::Unit::TestCase

  # Defines testing variables before each test runs.
  # A local and remote test repository are set up at
  # @base_dir+@local_dir and @base_dir+@remote_dir.
  #
  def setup
    @base_dir   = Dir.getwd + '/'
    @local_dir  = 'repo_1/'
    @remote_dir = 'repo_2/'

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



  # Tests pulling from a remote repo to an empty local repo.
  # This test asserts that commit history and staged files are preserved.
  #
  # Assumptions:
  #   - There is a method call to initialize an empty repository.
  #   - There is a method to stage a file.
  #   - There is a method to commit with a message.
  #   - There is a method to obtain the commit log.
  #   - There is a method to obtain a list of staged files.
  #
  def test_clean_pull
    # Create a commit history on the remote
    Dir.chdir(@remote_dir)
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

  # Tests pushing to an empty remote repo from a local repo.
  # This test asserts that commit history and staged files are preserved.
  #
  # Assumptions:
  #   - There is a method call to initialize an empty repository.
  #   - There is a method to stage a file.
  #   - There is a method to commit with a message.
  #   - There is a method to obtain the commit log.
  #   - There is a method to obtain a list of staged files.
  #
  def test_clean_push
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

end
