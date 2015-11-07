require 'io/console'
require 'net/ssh'
require 'etc'

class PushPull

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
      snapshot_history = Repo.history(local_latest_snapshot)

      # Raise an exception if the latest snapshot on the remote isn't part of the local history
      remote_snapshot_index = snapshot_history.index(remote_latest_snapshot)
      if (remote_snapshot_index.nil?)
        raise 'Local is not up to date, please pull and try again.'
        return
      end

      snapshots_to_merge = snapshot_history[0...remote_snapshot_index]

      # Merge the new local snapshots onto the remote
      last_snapshot = remote_latest_snapshot
      snapshots_to_merge.each { |snapshot|
        # TODO Need to somehow get this snapshot onto the new server, then merge by ID
        ssh.exec 'merge(last_snapshot, snapshot)'
        last_snapshot = snapshot
      }
    }
  end
  
end
