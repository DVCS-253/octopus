#Provides interface to the users in order to execute commands

require "#{File.dirname(__FILE__)}/../workspace/workspace.rb"
require "#{File.dirname(__FILE__)}/../push_pull/push_pull.rb"
require "#{File.dirname(__FILE__)}/../repo/repos.rb"
class UserInterface
	include PushPull
	
	#--List of supported commands
	SupportedCmds = ["init", "add", "checkout", "commit", "branch", "merge", "push", "pull", "status", "clone", "update", "diff", "get_latest_snapshot", "get_all_snapshots", "help"]
	
	#--Regular expressions for supported commands 
	InitRE = "init(\s+([^\s]*))?$"
	AddRE = "add\s*(((\s+(\"[^\s]*\"))*)|(\s+(\.))?)$"
	CheckoutRE = "checkout\s*(\s+([^\s]*))?\s*(\s+(-b)\s+([^\s]*))?\s*(\s+(--track)\s+([^\s]*/[^\s]*))?$"
	CommitRE = "commit(\s+(-a))?(\s+(-m)\s+(\"[^\"]*\"))?((\s+([^\s]*))*)$"
	BranchRE = "branch\s*(\s*(\s+(-a)\s+([^\s]*))|\s*(\s+(-d)\s+([^\s]*)))?$"
	MergeRE = "merge\s*(\s+([^\s]*)\s*)*$"
	PushRE = "push(\s+(origin))?(\s+([^\s]*))$"
	PullRE = "pull(\s+(origin))?(\s+([^\s]*))$"
	StatusRE = "status$"
	CloneRE = "clone\s*(\s+([^\s]+)\s*)\s*((\s+(\"[^\s]*\"))?)$"
	DiffRE = "diff(\s+([^\s]*))?(\s+([^\s]*))$"
	UpdateRE = "update(\s+([^\s]*))?$"
	GetLatestSnapshotRE = "get_latest_snapshot\s*(\s+([^\s]*)\s*)*$"
	GetAllSnapshotRE = "get_all_snapshots$"
	
	#--Correct usage of the commands
	InitUsg = 'init ["directory"]'
	AddUsg = 'add ([.] | ["file1"] ["file2"] ...)'
	CheckoutUsg = 'checkout [-b] [branch] [--track origin/branch]'
	CommitUsg = 'commit [-a] [-m "msg"] ["file1"]["file2"] ...'
	BranchUsg = 'branch ([-a] | [-d branch])'
	MergeUsg = 'merge [branch]'
	PushUsg = 'push [origin] [branch]'
	PullUsg = 'pull [origin] [branch]'
	StatusUsg = 'status'
	CloneUsg = 'clone repository ["directory"]'
	DiffUsg = 'diff commit1 commit2'
	UpdateUsg = 'update ["textfile"]'
	GetLatestSnapshotUsg = 'get_latest_snapshot [snapshot_id]' #returns error/success
	GetAllSnapshotUsg = 'get_all_snapshots' #returns error/success
	
	#Entry point of the application. Takes the 'command' from user in form of program arguments 
	#and pass it to 'parseCommand' method after basic syntax checking<br><br>
	#Params:
	# - testCommands: commands(String[]), applicable only when called from the unit test module
	#Returns:
	# - result: output(String) of execution
	def main(testCommands)
		if testCommands
			command = testCommands
		else 
			command = ARGV
		end 
		result = ""
		if !command.empty?
			command.each_with_index{|cmd,i|
				if cmd.split(' ').length>1
					command[i] = '"' + cmd + '"'
				end
			}
			command.each_with_index{|cmd,i| 
				if i==0 && SupportedCmds.include?(cmd)
					result = parseCommand(cmd,command*" ")
					break
				else
					result = "Invalid command '" + cmd + "'.\nCommands supported : " + SupportedCmds.to_s
			 	#result = "Invalid command '" + cmd + "'"
			 end
			}
			displayResult(result) #if !testCommands
		end
		return result
	end
	
	#Does the command pattern matching
	#and pass it to 'parseCommand' method after basic syntax checking<br><br>
	#Params:
	# - cmd(String): main command e.g. 'init', on the basis of which further pattern matching is done<br>
	# - fullCmd(String): full command along with its parameters
	#Returns:
	# - result(String): output of execution
	def parseCommand(cmd, fullCmd)
		result = ""
		if cmd == "init"
			matched = fullCmd.match InitRE
			if matched
				params = Hash.new
				params["directory"] = matched[2] if matched[2]
				p "about to call init"
				result = Workspace.new.init
			else
				result = "Incorrect format. Expected: " + InitUsg
			end
		elsif cmd == "add"
			matched = fullCmd.match AddRE
			if matched
				params = Hash.new
				if matched[2]
					files = matched[2].split(" ")
					files.each_with_index{|file,i| params[("file"+(i+1).to_s)]= file }
				end
				params["all"] = true if matched[5]
				result = executeCommand(cmd,params)
			else
				result = "Incorrect format. Expected: " + AddUsg
			end
		elsif cmd == "checkout"
			matched = fullCmd.match CheckoutRE
			if matched
				params = Hash.new
				existingBranch = matched[2] if matched[2]
				params["existingBranch"] = existingBranch
				params["createBranch"] = true if matched[4]
				params["newBranch"] = matched[5] if matched[5]
				params["track"] = matched[6] if matched[6]
				result = Workspace.new.check_out(existingBranch)
			else
				result = "Incorrect format. Expected: " + CheckoutUsg
			end	
		elsif cmd == "commit"
			matched = fullCmd.match CommitRE
			if matched
				params = Hash.new
				params["add"] = true if matched[2]
				params["msg"] = matched[5].gsub(/"/,'') if matched[4] and matched[5]
				if matched[6]
					files = matched[6].split(" ")
					# files.each_with_index{|file,i| params[("file"+(i+1).to_s)] = file }
					files.map! do |file| 
								file = Dir.pwd + "/" + file
							end
				end
				puts "Files passed for commit #{files.inspect}"
				result = Workspace.new.commit(files)
			else
				result = "Incorrect format. Expected: " + CommitUsg
			end	
		elsif cmd == "branch" # this should accept a branch name also
			matched = fullCmd.match BranchRE
			if matched
				params = Hash.new
				add = matched[2]
				if add
					branch = matched[4]
					Workspace.new.branch(branch)
				end
				#params["add"] = true if matched[2]
				#params["branch"] = matched[4] if matched[4]
				params["delete"] = true if matched[5]
				params["branch"] = matched[6] if matched[6]
				
			else
				result = "Incorrect format. Expected: " + BranchUsg
			end	
		elsif cmd == "merge"
			matched = fullCmd.match MergeRE
			if matched
				params = Hash.new
				params["branch"] = matched[2] if matched[2]
				result = executeCommand(cmd,params)
			else
				result = "Incorrect format. Expected: " + MergeUsg
			end	
		elsif cmd == "push"
			matched = fullCmd.match PushRE
			if matched
				params = Hash.new
				remote = matched[2] if matched[2]
				branch = matched[4] if matched[4]
				params["remote"] = remote
				params["branch"] = branch
				result = PushPull.push(remote,branch)
			else
				result = "Incorrect format. Expected: " + PushUsg
			end	
		elsif cmd == "pull"
			matched = fullCmd.match PullRE
			if matched
				params = Hash.new
				remote = matched[2] if matched[2]
				branch = matched[4] if matched[4]
				params["remote"] = remote
				params["branch"] = branch
				result = PushPull.pull(remote,branch)
			else
				result = "Incorrect format. Expected: " + PullUsg
			end	
		elsif cmd == "status"
			matched = fullCmd.match StatusRE
			if matched
				files = Workspace.new.status
				puts "->Uncommitted files/directories(#{files.size}):" if files.size>0
				files.each_with_index{|file,i| 
				puts "    "+red(file.to_s)
				}
			else
				result = "Incorrect format. Expected: " + StatusUsg
			end	
			
		elsif cmd == "clone"
			matched = fullCmd.match CloneRE
			if matched
				params = Hash.new
				repository = matched[2] if matched[2]
				directory = matched[5] if matched[5]
				params["repository"] = repository
				params["directory"] = directory
				result = PushPull.clone(repository,directory)
			else
				result = "Incorrect format. Expected: " + CloneUsg
			end	
		elsif cmd == "diff"
			matched = fullCmd.match DiffRE
			if matched
				params = Hash.new
				params["commit1"] = matched[2] if matched[2]
				params["commit2"] = matched[4] if matched[4]
				result = executeCommand(cmd,params)
			else
				result = "Incorrect format. Expected: " + DiffUsg
			end	
		elsif cmd == "update"
			matched = fullCmd.match UpdateRE
			if matched
				params = Hash.new
				params["textfile"] = matched[2] if matched[2]
				result = executeCommand(cmd,params)
			else
				result = "Incorrect format. Expected: " + UpdateUsg
			end	
		elsif cmd == "get_latest_snapshot"
			matched = fullCmd.match GetLatestSnapshotRE
			if matched
				params = Hash.new
				snapshot_id =  matched[2] if matched[2]
				params["snapshot_id"] = snapshot_id
				result = Repos.new.get_latest_snapshot(snapshot_id)
				p 
			else
				result = "Incorrect format. Expected: " + GetLatestSnapshotUsg
			end	
		elsif cmd == "get_all_snapshots"
			matched = fullCmd.match GetAllSnapshotRE
			if matched
				result = Repos.new.get_all_snapshots()
			else
				result = "Incorrect format. Expected: " + GetAllSnapshotUsg
			end	
		elsif cmd == "help"
			`cat help.txt`
		end
		return result
	end

	#Acts a method from other module. It will be replaced by actual method from other module<br><br>
	#Params:
	# - cmd(String): main command e.g. 'init'                          <br>
	# - params(Hash): key-value pairs of command parameters and their values
	#Returns:
	# - result(String): output of execution
	private
	def executeCommand(cmd, params)
		result = "Command: "+ cmd + "\nParameters: " + params.to_s
		return result
	end

	#Displays the result of execution of the command<br><br>
	#Params:
	# - result(String): result of the execution
	#Returns:
	# - result(String): result of the execution to the testing module
	private
	def displayResult(result)
		puts result
		p
		p
		result
	end

	#To colorize the output based on the color code
	private
	def colorize(text, color_code)
  		"\e[#{color_code}m#{text}\e[0m"
	end
	
	#To colorize the output to red
	private
	def red(text); colorize(text, 31); end 
	end
end

#'main' method invocation
#UserInterface.new.main(nil)
