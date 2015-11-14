require 'io/console'
require 'fileutils'
require 'net/ssh'
require 'repos'
require 'json'
require 'etc'

module PushPull

  @@repo = Repos.new

  private_class_method :pull_with_connection

  # Uses the Net::SSH gem to create an SSH session.
  # The user will be asked for their credentials for the connection,
  # unless they have a key configured for the connection.
  #
  # @param [string] remote The address of the remote machine to connect to.
  # @param [string] path The path to the corresponding repo on the remote.
  # @yield [ssh] Custom block for utilizing the connection.
  # @yieldparam [Net::SSH] ssh The ssh connection object.
  #
  def self.connect(remote, path)
    begin
      # Attempt to login as the current user with a key
      ssh = Net::SSH.start(remote, Etc.getlogin)
    rescue
      begin
        print 'Username: '
        username = STDIN.gets.chomp           # Remove trailing newline
        print 'Password: '
        password = STDIN.noecho(&:gets).chomp # Remove trailing newline
      
        ssh = Net::SSH.start(remote, username, :password => password)
      rescue
        raise 'Unable to connect to remote'
      end
    end

    ssh.exec "cd #{path}"

    if block_given?
      yield ssh
    end

    ssh.close
  end

  # Pushes new changes from the local repo to a remote repo.
  # An exception is raised if the user needs to pull before they can push.
  #
  # @param [string] remote The address of the remote machine to connect to.
  # @param [string] branch The name of the branch to push to.
  # 
  def self.push(remote, branch)
    self.connect(remote, path) { |ssh|
      remote_latest_snapshot = ssh.exec! "cat .oct/branches/#{branch}/latest_commit"

      local_latest_snapshot = IO.read(".oct/branches/#{branch}/latest_commit")
      snapshot_history = @@repo.history(local_latest_snapshot)

      # If the remote has a commit history
      if remote_latest_snapshot
        remote_snapshot_index = snapshot_history.index(remote_latest_snapshot)

        # Raise an exception if the latest snapshot on the remote isn't part of the local history
        raise 'Local is not up to date, please pull and try again' if remote_snapshot_index.nil?
        
        snapshots_to_merge = snapshot_history[0...remote_snapshot_index]
      else
        # Remote has no commit history, push all local commits
        snapshots_to_merge = snapshot_history
      end

      # Merge the new local snapshots onto the remote
      last_snapshot = remote_latest_snapshot
      snapshots_to_merge.each { |snapshot|
        # TODO Need to somehow get this snapshot onto the new server, then merge by ID
        ssh.exec 'merge(last_snapshot, snapshot)'
        last_snapshot = snapshot
      }
    }
  end

  # Pulls new changes from the remote repo to the local repo.
  # An exception is raised if the remote does not have the local HEAD in its history
  #
  # @param [string] remote The address of the remote machine to connect to.
  # @param [string] branch The name of the branch to pull.
  # 
  def self.pull(remote, branch)
    self.connect(remote, path) { |ssh|
      pull_with_connection(remote, path, ssh)
    }
  end

  # Pulls new changes from the remote repo to the local repo.
  # An exception is raised if the remote does not have the local HEAD in its history
  #
  # @param [string] remote The address of the remote machine to connect to.
  # @param [string] branch The name of the branch to pull.
  # @param [Net::SSH] ssh The ssh connection object to use.
  #
  def pull_with_connection(remote, branch, ssh)
    local_latest_snapshot = IO.read(".oct/branches/#{branch}/latest_commit")

    remote_latest_snapshot = ssh.exec! "cat .oct/branches/#{branch}/latest_commit"
    snapshot_history = # Somehow run Repo.history(remote_latest_snapshot) on the remote

    # If the local repo has a commit history
    if local_latest_snapshot
      local_snapshot_index = snapshot_history.index(local_latest_snapshot)

      # Raise an exception if the local latest snapshot isn't part of the remote's history
      raise 'Local commit history is not present on remote' if local_snapshot_index.nil?
      
      snapshots_to_merge = snapshot_history[0...local_snapshot_index]
    else
      # Local repo has no commit history, pull all remote commits
      snapshots_to_merge = snapshot_history
    end

    # Merge the new remote snapshots onto the local repo
    snapshots_to_merge.each { |snapshot|
      @@repo.update_tree(snapshot)
    }
  end

  # Clones all branches from the given remote repository to a local directory.
  # An exception is raised if the destination directory already exists
  #
  # @param [string] remote The address of the remote machine to clone.
  # @param [string] directory_name The name of the directory to clone the repo into.
  #                                Defaults to the name of the repository on the remote.
  #
  def self.clone(remote, directory_name = nil)
    # TODO The directory name should be the name of the repository by default
    directory_name = 'clone' if directory_name.nil?

    # Ensure the directory does not already exist
    raise 'Destination for clone already exists' if Dir.exists?(directory_name)

    Dir.mkdir(directory_name)

    # Initialize the new repository
    Dir.chdir(directory_name)
    @@repo.init()

    # TODO This is where we'd set up the origin remote
    
    self.connect(remote, path) { |ssh|
      # Obtain a list of branches on the remote
      branches = JSON.parse(ssh.exec! 'cat .oct/branch/branches')

      # Pull each branch
      branches.keys.each { |branch|
        pull_with_connection(remote, branch, ssh)
      }
    }
  end
end
