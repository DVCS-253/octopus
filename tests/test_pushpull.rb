require 'fileutils'
require 'test/unit'
require_relative '../PushPull'

# Tests public methods of the push/pull module.
#
# Test overview:
#   - Push
#     - Push to empty repo
#     - Push to repo with committed changes
#     - Push to repo with uncommitted changes
#   - Pull
#     - Pull into empty repo
#     - Pull into repo with committed changes
#     - Pull into repo with uncommitted changes
#   - Clone
#     - Clone remote repo with committed changes
#   - Connect
#     - Connects to the remote repo's machine
#
# Assumptions:
#   - There is a method to initialize an empty repository.
#   - There is a method to stage a file.
#   - There is a method to commit with a message.
#   - There is a method to obtain the commit log.
#   - There is a method to obtain a list of staged files.
#
class TestPushPull < Test::Unit::TestCase

  # Defines testing variables before each test runs.
  # A local and remote test repository are set up,
  # and can be modified by passing a block to
  # `in_local_repo` and `in_remote_repo`.
  #
  def setup
    # Repo directories on the filesystem
    @base_dir   = Dir.getwd + '/'
    @local_dir  = 'local_repo/'
    @remote_dir = 'remote_repo/'
    @clone_dir  = 'clone_repo/'

    # Network address for the repos
    @machine_url = '127.0.0.1'

    # a.txt contains A words, b.txt contains B words
    @files = ['a.txt', 'b.txt']

    @local_file_contents = [
      'apple  \n algorithm \n API \n APL',
      'binary \n bit       \n byte'
    ]
    @remote_file_contents = [
      'apple  \n algorithm \n APL',
      'binary \n byte'
    ]

    @local_commit_messages = [
      'Added "API" to A words',
      'Added "bit" to B words'
    ]
    @remote_commit_messages = [
      'Created file with A words',
      'Created file with B words'
    ]

    # Initialize a local and remote repository in their respective directories
    Dir.mkdir(@local_dir, 0755)
    Dir.mkdir(@remote_dir, 0755)
    init(@local_dir)
    init(@remote_dir)
  end

  # Cleans up the test repositories after each test.
  #
  def teardown
    FileUtils.rm_rf(@local_dir)
    FileUtils.rm_rf(@remote_dir)
    FileUtils.rm_rf(@clone_dir) if Dir.exist? @clone_dir
  end


  #
  # Test helpers
  #


  # Runs the given block inside the local repo.
  #
  def in_local_repo
    Dir.chdir(@base_dir + @local_dir)
    yield
    Dir.chdir(@base_dir)
  end

  # Runs the given block inside the remote repo.
  #
  def in_remote_repo
    Dir.chdir(@base_dir + @remote_dir)
    yield
    Dir.chdir(@base_dir)
  end

  # Runs the given block inside the cloned repo.
  #
  def in_clone_repo
    Dir.chdir(@base_dir + @clone_dir)
    yield
    Dir.chdir(@base_dir)
  end


  #
  # Tests
  #


  # Tests connecting to a machine.
  #
  def test_connect
    # Assert that the machine can be connected to
    assert_not_raises(PushPull.connect(@machine_url, @base_dir + @remote_dir),
                      'Failed to connect to remote machine.')
  end


  # Tests pulling from a remote repo to an empty local repo.
  # This test asserts that commit history and staged files are preserved.
  #
  def test_pull_into_empty_repo
    # Create file 1 with committed changes on the remote
    in_remote_repo {
      File.write(@files[0], @remote_file_contents[0])
      stage(@files[0])
      commit(@remote_commit_messages[0])
    }

    # Pull into the empty local repo and assert for correctness
    in_local_repo {
      pull(@remote_url)

      assert_equal(@remote_commit_messages[0], get_last_commit_message(),
                   'Commit history was not preserved when pulling from remote.')

      assert_equal([@files[0]], get_staged_files(),
                   'List of staged files was not preserved when pulling from remote.')

      assert_equal(@remote_file_contents[0], File.read(@files[0]),
                   'File contents were not preserved when pulling from remote.')
    }
  end

  # Tests pulling from a remote repo to a local repo with committed changes.
  # This test asserts that commit history and staged files are preserved.
  #
  def test_pull_into_committed_repo
    # Create file 1 with committed changes locally
    in_local_repo {
      File.write(@files[0], @local_file_contents[0])
      stage(@files[0])
      commit(@local_commit_messages[0])
    }

    # Pull from local and create a commit history on the remote for file 1 and 2
    in_remote_repo {
      pull(@local_url)

      # Modify file 1 and commit the changes
      File.write(@files[0], @remote_file_contents[0])
      stage(@files[0])
      commit(@remote_commit_messages[0])

      # Create file 2 and commit it
      File.write(@files[1], @remote_file_contents[1])
      stage(@files[1])
      commit(@remote_commit_messages[1])
    }

    # Pull into the local repository
    in_local_repo {
      pull(@remote_url)

      # Ensure the commit for changing file 1 is present
      assert_equal(@remote_commit_messages[0], get_second_to_last_commit_message(),
                   'Commit history was not preserved when pulling from remote.')

      # Ensure the commit for creating file 2 is present
      assert_equal(@remote_commit_messages[1], get_last_commit_message(),
                   'Commit history was not preserved when pulling from remote.')

      # Ensure that file 1 and 2 are staged
      assert_equal([@files[0], @files[1]], get_staged_files(),
                   'List of staged files was not preserved when pulling from remote.')

      # Ensure that the changes to file 1 were merged
      assert_equal(@remote_file_contents[0], File.read(@files[0]),
                   'File contents were not merged when pulling from remote.')

      # Ensure that file 2 was created
      assert_equal(@remote_file_contents[1], File.read(@files[1]),
                   'File contents were not preserved when pulling from remote.')
    }
  end

  # Tests pulling from a remote repo to a local repo with uncommitted changes.
  # This test asserts that an exception is raised.
  #
  def test_pull_into_uncommitted_repo
    # Create file 1 with uncommitted changes locally
    in_local_repo {
      File.write(@files[0], @local_file_contents[0])
      stage(@files[0])
    }

    # Create file 1 with committed changes on the remote
    in_remote_repo {
      File.write(@files[0], @remote_file_contents[0])
      stage(@files[0])
      commit(@remote_commit_messages[0])
    }

    # Assert that pulling from the remote with uncommitted local changes raises an exception
    in_local_repo {
      assert_raise do
        pull(@remote_url)
      end
    }
  end


  # Tests cloning a remote repo into a new directory.
  # This test asserts that commit history and staged files are preserved.
  #
  def test_clone
    # Create and commit file 1 on the remote
    in_remote_repo {
      File.write(@files[0], @remote_file_contents[0])
      stage(@files[0])
      commit(@remote_commit_messages[0])
    }

    # Clone the remote repo into a new folder called @clone_dir
    clone(@remote_url, @clone_dir)

    # Assert that the clone directory was created
    assert(Dir.exist? @clone_dir,
          'Directory to clone into was not created.')

    # Assert that the clone repo is identical to the remote
    in_clone_repo {
      assert_equal(@remote_commit_messages[0], get_last_commit_message(),
                   'Commit history was not preserved when cloning remote.')

      assert_equal([@files[0]], get_staged_files(),
                   'List of staged files was not preserved when cloning remote.')

      assert_equal(@remote_file_contents[0], File.read(@files[0]),
                   'File contents were not preserved when cloning remote.')
    }
  end


  # Tests pushing to an empty remote repo from a local repo.
  # This test asserts that commit history and staged files are preserved.
  #
  def test_push_to_empty_repo
    # Create and commit file 1 locally, then push to the empty remote
    in_local_repo {
      File.write(@files[0], @local_file_contents[0])
      stage(@files[0])
      commit(@local_commit_messages[0])

      push(@remote_url)
    }

    # Assert that the remote is identical to the local
    in_remote_repo {
      assert_equal(@local_commit_messages[0], get_last_commit_message(),
                   'Commit history was not preserved when pushing to remote.')

      assert_equal([@files[0]], get_staged_files(),
                   'List of staged files was not preserved when pushing to remote.')

      assert_equal(@local_file_contents[0], File.read(@files[0]),
                   'File contents were not preserved when pushing to remote.')
    }
  end

  # Tests pushing to a remote repo with committed changes from a local repo.
  # This test asserts that commit history and staged files are preserved.
  #
  def test_push_to_committed_repo
    # Create and commit file 1 on the remote
    in_remote_repo {
      File.write(@files[0], @remote_file_contents[0])
      stage(@files[0])
      commit(@remote_commit_messages[0])
    }

    in_local_repo {
      # Pull the remote into the empty local repo
      pull(@remote_url)

      # Modify file 1 and commit the changes
      File.write(@files[0], @local_file_contents[0])
      stage(@files[0])
      commit(@local_commit_messages[0])

      # Create and commit file 2
      File.write(@files[1], @local_file_contents[1])
      stage(@files[1])
      commit(@local_commit_messages[1])

      # Push the changes from local to the remote
      push(@remote_url)
    }

    # Assert that the commit history and staged files are correct on the remote
    in_remote_repo {
      # Ensure the commit for changing file 1 is present
      assert_equal(@local_commit_messages[0], get_second_to_last_commit_message(),
                   'Commit history was not preserved when pushing to remote.')

      # Ensure the commit for creating file 2 is present
      assert_equal(@local_commit_messages[1], get_last_commit_message(),
                   'Commit history was not preserved when pushing to remote.')

      # Ensure that file 1 and 2 are staged
      assert_equal([@files[0], @files[1]], get_staged_files(),
                   'List of staged files was not preserved when pushing to remote.')

      # Ensure the changes to file 1 were merged correctly
      assert_equal(@local_file_contents[0], File.read(@files[0]),
                   'File contents were not merged when pushing to remote.')

      # Ensure that file 2 was created
      assert_equal(@local_file_contents[1], File.read(@files[1]),
                   'File contents were not preserved when pushing to remote.')
    }
  end

  # Tests pushing to a remote repo with uncommitted changes from a local repo.
  # This test asserts that an exception is raised.
  #
  def test_push_to_uncommitted_repo
    # Create and stage file 1 with uncommitted changes on the remote
    in_remote_repo {
      File.write(@files[0], @remote_file_contents[0])
      stage(@files[0])
    }

    # Create and commit file 1 locally
    in_local_repo {
      File.write(@files[0], @local_file_contents[0])
      stage(@files[0])
      commit(@local_commit_messages[0])
    }

    # Assert that pushing to the remote with uncommitted changes raises an exception
    in_local_repo {
      assert_raise do
        push(@remote_url)
      end
    }
  end

end
