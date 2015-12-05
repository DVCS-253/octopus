require_relative "#{File.dirname(__FILE__)}/../repo/repos"
require_relative "#{File.dirname(__FILE__)}/../workspace/workspace"
require 'io/console'
require 'shellwords'
require 'fileutils'
require 'net/sftp'
require 'net/ssh'
require 'json'

module PushPull

  @@dvcs_dir   = '.octopus' # Name of the directory containing the DVCS files
  @@repo_dir   = File.join(@@dvcs_dir, 'repo')
  @@comm_dir   = File.join(@@dvcs_dir, 'communication')
  @@revlog_dir = File.join(@@dvcs_dir, 'revlog')
  @@comm_file  = File.join(@@comm_dir, 'text_file')

  # Uses the Net::SSH gem to create an SSH session.
  # The user will be asked for their credentials for the connection,
  # unless they have a key configured for the connection.
  #
  # @param [string] user The user to connect to the remote as.
  # @param [string] remote The address of the remote machine to connect to.
  # @yield [ssh] Custom block for utilizing the connection.
  # @yieldparam [Net::SSH] ssh The ssh connection object.
  #
  def self.connect(user, remote)
    begin
      # Attempt to login as the current user with a key
      ssh  = Net::SSH.start(remote, user)
    rescue
      begin
        print 'Username: '
        username = STDIN.gets.chomp           # Remove trailing newline
        print 'Password: '
        password = STDIN.noecho(&:gets).chomp # Remove trailing newline
      
        ssh  = Net::SSH.start(remote, username, :password => password)
      rescue
        return 'Unable to connect to remote'
      end
    end

    if block_given?
      yield ssh
    end

    ssh.close
  end

  # Pushes new changes from the local repo to a remote repo.
  # An exception is raised if the user needs to pull before they can push.
  #
  # @param [string] remote The address of the remote machine to connect to.
  #                        For example: user@127.0.0.1:/path/to/repo
  #                        This also works without a user specified.
  # @param [string] branch The name of the branch to push to.
  # 
  def self.push(remote, branch)
    # Splits user@127.0.0.1:/path/to/repo into user, 127.0.0.1, and /path/to/repo
    user, remote  = remote.split('@', 2)
    remote = user if remote.empty?
    address, path = remote.split(':', 2)

    self.connect(user, address) { |ssh, sftp|
      # Get the HEAD of the remote branch
      file_exists = ssh.exec! "if [ -f #{File.join(path, @@repo_dir)}/branches ]; then echo 1; else echo 0 fi"
      if file_exists == '1'
        branch_file  = ssh.exec! "cat #{File.join(path, @@repo_dir)}/branches"
        branch_table = Marshal.load(branch_file)
        remote_head  = branch_table[branch]
      else
        raise 'Remote does not appear to be an octopus repository' if branch != 'master'
        remote_head = '0'
      end

      # Get all local changes since the remote HEAD
      Repos.get_latest_snapshots(remote_head)
      local_changes = File.binread(@@comm_file)

      # Raise an exception if local changes could not be calculated
      return 'Local is not up to date, please pull and try again' if !Marshal.load(local_changes)

      # Copy the contents of the local file to remote/#{@@dvcs_dir}/communication/text_file
      ssh.sftp.upload!(@@comm_file, File.join(path, @@comm_file))

      #puts "Wrote to #{File.join(path, @@comm_file)}"
      # Merge the new snapshots into the remote
      ssh.exec "cd #{path} && oct update #{@@comm_file}"

      # TODO Checkout current branch on remote
      ssh.exec "cd #{path} && oct checkout #{branch}"
    }
  end

  # Pulls new changes from the remote repo to the local repo.
  # An exception is raised if the remote does not have the local HEAD in its history
  #
  # @param [string] remote The address of the remote machine to connect to.
  #                        For example: 127.0.0.1:/path/to/repo
  # @param [string] branch The name of the branch to pull.
  # 
  def self.pull(remote, branch)
    # Splits user@127.0.0.1:/path/to/repo into user, 127.0.0.1, and /path/to/repo
    user, remote  = remote.split('@', 2)
    remote = user if remote.empty?
    address, path = remote.split(':', 2)

    self.connect(user, address) { |ssh, sftp|
      pull_with_connection(branch, path, ssh)
    }
  end

  # Pulls new changes from the remote repo to the local repo.
  # An exception is raised if the remote does not have the local HEAD in its history,
  # or if the given branch does not exist locally or on the remote.
  #
  # This method should be considered private.
  #
  # @param [string] branch The name of the branch to pull.
  # @param [string] path The path to the repo on the remote.
  # @param [Net::SSH] ssh The ssh connection object to use.
  #
  def self.pull_with_connection(branch, path, ssh)
    local_head = Repos.get_head(branch)

    if !Workspace.new.status.empty?
      raise 'Refusing to pull, you have uncommitted local changes'
    end

    # Calling either of these `oct func` methods updates
    # the #{@@dvcs_dir}/communication/text_file file on the remote
    if local_head.nil?
      # Get the entire history if our locally history is empty
      to_merge = ssh.exec! "cd #{path} && oct get_all_snapshots"
    else
      # Get the history since our latest local snapshot
      id = Marshal.load(local_head).snapshot_ID
      ssh.exec! "cd #{path} && oct get_latest_snapshot #{Shellwords.shellescape(id)}"
      to_merge = ssh.exec! "cat #{path}/#{@@comm_file}"
    end

    File.open(@@comm_file, 'wb') { |f| f.write(to_merge) }
    
    # Update our local snapshot tree
    Repos.update_tree(@@comm_file)

    # Reload the current branch so any new files will show up
    Workspace.new.check_out_branch(Repos.get_current_branch)
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
    directory_name = directory_name.nil? ? File.basename(remote) : directory_name

    # Ensure the directory does not already exist
    return 'Destination for clone already exists' if Dir.exists?(directory_name)

    Dir.mkdir(directory_name)

    # Initialize the new repository
    Dir.chdir(directory_name) {
      workspace = Workspace.new
      workspace.init

      # Splits user@127.0.0.1:/path/to/repo into user, 127.0.0.1, and /path/to/repo
      user, remote  = remote.split('@', 2)
      remote = user if remote.empty?
      address, path = remote.split(':', 2)
      self.connect(user, address) { |ssh, sftp|
        head_file   = ssh.exec! "cat #{path}/#{@@repo_dir}/head"
        store_file  = ssh.exec! "cat #{path}/#{@@repo_dir}/store"
        revlog_file = ssh.exec! "cat #{path}/#{@@revlog_dir}/revlog.json"
        branch_file = ssh.exec! "cat #{path}/#{@@repo_dir}/branches"

        File.open("#{@@repo_dir}/head",          'wb') { |f| f.write(head_file)   }
        File.open("#{@@repo_dir}/store",         'wb') { |f| f.write(store_file)  }
        File.open("#{@@repo_dir}/branches",      'wb') { |f| f.write(branch_file) }
        File.open("#{@@revlog_dir}/revlog.json", 'wb') { |f| f.write(revlog_file) }

        workspace.check_out_branch("master")
      }

      File.open("#{@@repo_dir}/head", 'wb'){|f| f.write(@head_file)}
      File.open("#{@@repo_dir}/store", 'wb'){|f| f.write(@store_file)}
      File.open("#{@@repo_dir}/branches", 'wb'){|f| f.write(@branch_file)}
      File.open("#{@@revlog_dir}/revlog.json", 'wb'){|f| f.write(@revlog_file)}
      workspace.check_out_branch("master")
    }
    return "You have succesfully cloned from #{remote}"
  end
end
