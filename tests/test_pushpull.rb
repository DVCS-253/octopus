require 'fileutils'
require 'test/unit'

class TestPushPull < Test::Unit::TestCase

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
    local  = 'repo_1/'
    remote = 'repo_2/'
    remote_file = 'a.txt'
    remote_file_contents = 'apple\nalgorithm\nAPL'
    remote_commit_message = 'Added A words'
    
    # Initialize a local and remote repository
    Dir.mkdir(local, 0755)
    Dir.mkdir(remote, 0755)
    init(local)
    init(remote)

    # Create a commit history on the remote
    Dir.chdir(remote)
    File.write(remote_file, remote_file_contents)
    stage(remote_file)
    commit(remote_commit_message)

    # Change to the local repository and pull
    Dir.chdir('../'+local)
    pull('127.0.0.1/'+Dir.getwd+'/'+remote)

    # Assert that the commit history and staged files are correct
    assert_equal(remote_commit_message, get_last_commit_message(),
                 'Commit history was not preserved when pulling from remote.')
    assert_equal([remote_file], get_staged_files(),
                 'List of staged files was not preserved when pulling from remote.')
    assert_equal(remote_file_contents, File.read(remote_file),
                 'File contents were not preserved when pulling from remote.')

    # Clean up
    Dir.chdir('..')
    FileUtils.rm_rf(local)
    FileUtils.rm_rf(remote)
  end

  # Tests pushing to a remote over the network.
  #
  def test_push
    # Push to a test remote on localhost
    # Assert that the contents on the remote are as expected
  end
 
end
