require 'highline/import'
require 'net/ssh'

class PushPull

  # Uses the Net::SSH gem to create an SSH session.
  #
  # @param [string] remote The address of the remote machine to connect to.
  # @param [string] path The path to the corresponding repo on the remote.
  # @yield [ssh] Custom block for utilizing the connection.
  # @yieldparam [Net::SSH] ssh The ssh connection object.
  #
  def self.connect(remote, path)
    begin
      username = ask("Username: ") { |q| q.echo = true }
      password = ask("Password: ") { |q| q.echo = "*" }

      ssh = Net::SSH.start(remote, username, :password => password)
      ssh.exec "cd #{path}"
    rescue
      raise 'Unable to connect to remote'
    end

    yield ssh
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
      latest_snapshot = ssh.exec! "cat .oct/branches/#{branch}/latest_commit"

      #if (latest_commit is not in local history)
        #raise 'Local is not up to date, please pull and try again.'
        #return
      #end

      #Use latest remote snapshot to build a list of local snapshots since that one
      #Have the remote merge those snapshots one by one on the given branch
      #new_snapshots.each { |snapshot|
        #ssh.exec merge(new_snapshot, some_other_snapshot?)
      #}
    }
  
end
