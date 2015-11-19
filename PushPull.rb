require 'io/console'
require 'fileutils'
require 'tempfile'
require 'net/ssh'
require 'repos'
require 'json'
require 'etc'

module PushPull

  @@repo = Repos.new
  @@dvcs_dir = '.octopus' # Name of the directory containing the DVCS files

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
      remote_head = ssh.exec! "oct get_head #{branch}"

      local_changes = @@repo.get_latest_snapshots(remote_head)

      # Raise an exception if local changes could not be calculated
      raise 'Local is not up to date, please pull and try again' if !local_changes

      # Copy the contents of the local file to remote/#{@@dvcs_dir}/communication/text_file
      ssh.exec "echo #{Shellwords.shellescape(IO.read(local_changes))} > #{@@dvcs_dir}/communication/text_file"

      # Merge the new snapshots into the remote
      ssh.exec "oct update_tree #{@@dvcs_dir}/communication/text_file"
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
  # An exception is raised if the remote does not have the local HEAD in its history,
  # or if the given branch does not exist locally or on the remote.
  #
  # @param [string] remote The address of the remote machine to connect to.
  # @param [string] branch The name of the branch to pull.
  # @param [Net::SSH] ssh The ssh connection object to use.
  #
  def pull_with_connection(remote, branch, ssh)
    local_head = @@repo.get_head(branch)

    # Calling either of these `oct func` methods updates
    # the #{@@dvcs_dir}/communication/text_file file on the remote
    if local_head.nil?
      # Get the entire history if our locally history is empty
      if ssh.exec! "oct func get_all_snapshots" == 'error'
        raise 'Remote has no commit history'
      end
    else
      # Get the history since our latet local snapshot
      if ssh.exec! "oct func get_latest_snapshot #{local_head}" == 'error'
        raise 'Local commit history is not present on remote'
      end
    end

    # Merge the new remote snapshots into the local repo
    TempFile.open('snapshots_to_merge') { |file|
      # Copy over the file contents from the remote
      file.write(ssh.exec! "cat #{@@dvcs_dir}/communication/text_file")

      # Update our local snapshot tree
      @@repo.update_tree(file.path)
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
    # The directory name is the name of the repository by default
    directory_name = directory_name.nil? ? 'clone' : File.basename(remote)

    # Ensure the directory does not already exist
    raise 'Destination for clone already exists' if Dir.exists?(directory_name)

    Dir.mkdir(directory_name)

    # Initialize the new repository
    Dir.chdir(directory_name)
    @@repo.init()

    self.connect(remote, path) { |ssh|
      # Obtain a list of branches on the remote
      branches = JSON.parse(ssh.exec! "cat #{@@dvcs_dir}/repo/branches")

      # Pull each branch
      branches.keys.each { |branch|
        pull_with_connection(remote, branch, ssh)
      }
    }
  end
end
