#Provides interface to the users in order to execute commands

require "#{File.dirname(__FILE__)}/../workspace/workspace.rb"
require "#{File.dirname(__FILE__)}/../push_pull/push_pull.rb"
require "#{File.dirname(__FILE__)}/../repo/repos.rb"
class UserInterface
	include PushPull

  # Flag for printing the octopus
  # Some commands give output which needs to be parsed
  # Removing the octopus makes that parsing easier
  @print_octopus = true
	
	#--List of supported commands
	SupportedCmds = ["init", "add", "checkout", "commit", "branch", "merge", "push", "pull", "status", "clone", "update", "diff", "get_latest_snapshot", "get_all_snapshots", "current_branch", "help"]
	
	#--Regular expressions for supported commands 
	InitRE = "init(\s+([^\s]*))?$"
	AddRE = "add\s*(((\s+(\"[^\s]*\"))*)|(\s+(\.))?)$"
	CheckoutRE = "checkout\s*(\s+([^\s]*))?\s*(\s+(-b)\s+([^\s]*))?\s*(\s+(--track)\s+([^\s]*/[^\s]*))?$"
	CommitRE = "commit(\s+(-a))?(\s+(-m)\s+([^\s]*))?((\s+([^\s]*))*)$"
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
	CurrentBranchRE = "current_branch$"
	GetHeadRE = "get_head\s*(\s+([^\s]*)\s*)*$"
	
	#--Correct usage of the commands
	InitUsg = 'init ["directory"]'
	AddUsg = 'add ([.] | ["file1"] ["file2"] ...)'
	CheckoutUsg = 'checkout [-b] [branch] [--track origin/branch]'
	CommitUsg = 'commit [-a] [-m "msg"] ["file1"]["file2"] ...'
	BranchUsg = 'branch ([-a branch] | [-d branch])'
	MergeUsg = 'merge [branch]'
	PushUsg = 'push [origin] [branch]'
	PullUsg = 'pull [origin] [branch]'
	StatusUsg = 'status'
	CloneUsg = 'clone repository ["directory"]'
	DiffUsg = 'diff commit1 commit2'
	UpdateUsg = 'update ["textfile"]'
	GetLatestSnapshotUsg = 'get_latest_snapshot [snapshot_id]' #returns error/success
	GetAllSnapshotUsg = 'get_all_snapshots' #returns error/success
	CurrentBranchUsg = 'current_branch' #returns error/success
	GetHeadUsg = 'get_all_snapshots' #returns error/success
	
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
    @print_octopus = true # Default value

		result = ""
		if cmd == "init"
			matched = fullCmd.match InitRE
			if matched
				params = Hash.new
				params["directory"] = matched[2] if matched[2]
				result = Workspace.new.init
				# Workspace.new.commit(nil)
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
				result = Workspace.new.check_out_branch(existingBranch)
			else
				result = "Incorrect format. Expected: " + CheckoutUsg
			end	
		elsif cmd == "commit"
			matched = fullCmd.match CommitRE
			if matched
				params = Hash.new
				params["add"] = true if matched[2]
				message = matched[5].gsub(/"/,'') if matched[4] and matched[5]
				params["msg"] = message
				if matched[6]
					if matched[6] == " ."
						files = nil
					else
						files = matched[6].split(" ")
					# files.each_with_index{|file,i| params[("file"+(i+1).to_s)] = file }
					base_dir = File.read('.octopus/base_dir')
					# puts base_dir
					files.map! do |file| 
						file = file.gsub(/"#{base_dir}"/, "")
						if (file.match(/\A\//))
							file = file.gsub(/\A\//, "")
						end
						file
					end
					# puts files.inspect
					Workspace.new.commit(files, message)
				end
			end
			# puts "Files passed for commit #{files.inspect}"
				result = Workspace.new.commit(files, message)  #replace by commit(files, message) once the commit method supports it 
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
					puts "You are trying to make a branch called #{branch}"
					result = Repos.make_branch(branch)
				else
					branches = Repos.get_all_branches_names
					unless branches.nil?
						current_branch = Repos.get_current_branch
						puts "🐙  => You have #{branches.count} active branches"
						branches.each do |branch_name|
							if branch_name == current_branch
								colored_output = colorize("*#{branch_name}", 32)
								puts colored_output 
							else
								puts branch_name
							end
						end
					end
					result = "done"
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
			# matched = fullCmd.match PushRE
			# if matched
			# 	params = Hash.new
			# 	remote = matched[2] if matched[2]
			# 	branch = matched[4] if matched[4]
			# 	params["remote"] = remote
			# 	params["branch"] = branch
			# 	result = PushPull.push(remote,branch)
			# else
			# 	result = "Incorrect format. Expected: " + PushUsg
			# end
			r = fullCmd.split
			# r0 = remote, r1 = branch
			puts r.inspect
			result = PushPull.push(r[1],r[2])

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
				puts "  Uncommitted files/directories(#{files.size}):" if files.size>0
				files.each_with_index{|file,i| 
					puts "    "+red(file.to_s)
				}
				result = "Current branch: " + Repos.get_current_branch
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
				# puts params.inspect
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
      @print_octopus = false

			matched = fullCmd.match UpdateRE
			if matched
				params = Hash.new
				textfile = matched[2] if matched[2]
				params["textfile"] = textfile
<<<<<<< HEAD
				puts "Calling repos update file #{textfile}"
=======
>>>>>>> fe18270ab21a39eb2a6c9855d275fd161f726b7b
				Repos.update_tree(textfile) #textfile will be a filename
				#result = executeCommand(cmd,params)
			else
				result = "Incorrect format. Expected: " + UpdateUsg
			end	
		elsif cmd == "get_latest_snapshot" # unused by push and pull
      @print_octopus = false

			matched = fullCmd.match GetLatestSnapshotRE
			if matched
				params = Hash.new
				snapshot_id =  matched[2] if matched[2]
				params["snapshot_id"] = snapshot_id
				result = Repos.get_latest_snapshots(snapshot_id)
			else
				result = "Incorrect format. Expected: " + GetLatestSnapshotUsg
			end	
		elsif cmd == "get_all_snapshots"
      @print_octopus = false

			matched = fullCmd.match GetAllSnapshotRE
			msg = ""
			if matched
				result = Repos.get_all_snapshots()
				if result
					msg = "success"
				else
					msg = "error"
				end
			else
				result = "Incorrect format. Expected: " + GetAllSnapshotUsg
			end	
			msg
		elsif cmd == "current_branch"
      @print_octopus = false

			matched = fullCmd.match CurrentBranchRE
			msg = ""
			if matched
				result = Repos.get_current_branch()
				if result
					msg = "success"
				else
					msg = "error"
				end
			else
				result = "Incorrect format. Expected: " + CurrentBranchUsg
			end	
			msg
		elsif cmd == "get_head"
			matched = fullCmd.match GetHeadRE
			msg = ""
			if matched
				params = Hash.new
				branchname = matched[2] if matched[2]
				params["branch"] = branchname
				result = Repos.get_head(branchname)
				if result
					msg = "success"
				else
					msg = "error"
				end
			else
				result = "Incorrect format. Expected: " + GetLatestSnapshotUsg
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
    	print " 🐙  => " if @print_octopus
		puts result.to_s
	end

	#To colorize the output based on the color code
	private
	def colorize(text, color_code)
		"\e[#{color_code}m#{text}\e[0m"
	end
	
	#To colorize the output to red
	private
	def red(text) 
		colorize(text, 31)
	end 
end

#'main' method invocation
#UserInterface.new.main(nil)
