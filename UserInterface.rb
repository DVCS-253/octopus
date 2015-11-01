#This class contains the implementation of the user interface. 
#The implementation is limited to checking the basic commands only. The options of the commands
#are not included yet. 

class UserInterface
	#Used as a command starting keyword, just as 'git' in GitHub
	Start_keyword = "vcs"
	
	#Keywords used to exit the application. Any of the one can be used
	End_Keywords = ["quit","q","exit","end"]
	
	#List of valid commands. This list is used to compare with user's input
	Valid_Commands = ["init", "add", "checkout", "commit", "branch", "merge", "push", "pull", "status", "clone", "update", "diff", "help"]
	
	InitRe = "init(\s+(\"[^\"]*\"))?$"
	AddRe = "add\s*(((\s+(\"[^\s]*\"))*)|(\s+(\.))?)$"
	CheckoutRe = "checkout\s*(\s+([^\s]*))?\s*(\s+(-b)\s+([^\s]*))?\s*(\s+(--track)\s+([^\s]*/[^\s]*))?$"
	CommitRe = "commit(\s+(-a))?(\s+(-m)\s+(\"[^\"]*\"))?((\s+(\"[^\s]*\"))*)$"
	BranchRe = "branch\s*((\s+(-a))|\s*(\s+(-d)\s+([^\s]*)))?$"
	MergeRe = "merge\s*(\s+([^\s]*)\s*)*$"
	PushRe = "push(\s+(origin))?(\s+([^\s]*))$"
	PullRe = "pull(\s+(origin))?(\s+([^\s]*))$"
	StatusRe = "status$"
	CloneRe = "clone\s*(\s+([^\s]+)\s*)\s*((\s+(\"[^\s]*\"))?)$"
	DiffRe = "diff(\s+([^\s]*))?(\s+([^\s]*))$"
	
	
	InitOpt = 'init ["directory"]'
	AddOpt = 'add ([.] | ["file1"] ["file2"] ...)'
	CheckoutOpt = 'checkout [-b] [branch] [--track origin/branch]'
	CommitOpt = 'commit [-a] [-m "msg"] ["file1"]["file2"] ...'
	BranchOpt = 'branch ([-a] | [-d branch])'
	MergeOpt = 'merge [branch]'
	PushOpt = 'push [origin] [branch]'
	PullOpt = 'pull [origin] [branch]'
	StatusOpt = 'status'
	CloneOpt = 'clone repository ["directory"]'
	DiffOpt = 'diff commit1 commit2'

	#This is the original 'main' method. This method scans for the user input. 
	#A new 'main' method has been defined for testing purpose that takes parameterized input. 
	def main
		puts "Welcome to DVCS! For help, enter 'vcs help'"
		$stdin.each_line do |line|
    		output = parseCommand(line)
    		displayResult(output)
  		end
	end
	
	#This method has been defined for testing purpose. It takes parameterized input.
	#def main(input)
	#	#puts "Welcome to DVCS!"
    #	output = parseCommand(input)
    #	displayResult(output)
	#end
	
	#This method parses the input and collects the command as a token in form of array. It also does syntax checking 
	def parseCommand(line)
		command = []
		msg = ""
		if line
			line.split(" ").each_with_index{|c,i| 
				if i==0
					if End_Keywords.include?c 
						puts "Thank you!"
						exit 0
						#raise "Application exit requested!"
				    elsif c != Start_keyword
						msg = "Command should start with '" + Start_keyword + "'"
						break
					end
				else 
					command.push(c)
				end
			}
			if !command.empty?
				output = executeCommand(command)
				return output
			else
				return msg
			end
		end
	end
	
	#This method checks for the valid command and transfers control to another module's method for command execution
	def executeCommand(command)
		if !command.empty?
			command.each_with_index{|c,i| 
			if i==0 && Valid_Commands.include?(c)
				#output = fromOtherModule(c) 
				output = match(c,command*" ")
				return output
			else
			 	#msg = "Invalid command '" + c + "'.\nOnly the following commands are valid : " + Valid_Commands.to_s
			 	msg = "Invalid command '" + c + "'"
			 	return msg
			end
			}
		end
	end
	
	#This method display the final output sent from other modules
	def displayResult(output)
		puts output
		output
	end
	
	#This is a temporary method that is acting as a method from another module. It is created for testing purpose.
	def fromOtherModule(c,params)
		outp = "Command : "+ c + " Parameters : " + params.to_s
		return outp
	end
	
	def match(c, fc)
	 if c == "init"
	 o = fc.match InitRe
	 	if o
	 		params = Hash.new
	 		params["directory"] = o[2] if o[2]
	 		outp = fromOtherModule(c,params)
	 		return outp
	 	else
	 		msg = "Expected command : " + InitOpt
	 		return msg
	 	end
	 elsif c=="add"
	 	o = fc.match AddRe
	 	if o
	 		params = Hash.new
	 		if o[2]
	 			files = o[2].split(" ")
	 			files.each_with_index{|file,i| params[("file"+(i+1).to_s)]= file }
	 		end
	 		params["all"] = true if o[5]
	 		outp = fromOtherModule(c,params)
	 		return outp
	 	else
	 		msg = "Expected command : " + AddOpt
	 		return msg
	 	end
	 elsif c=="checkout"
	 	o = fc.match CheckoutRe
	 	if o
	 		params = Hash.new
	 		params["existingBranch"] = o[2] if o[2]
	 		params["createBranch"] = true if o[4]
	 		params["newBranch"] = o[5] if o[5]
	 		params["track"] = o[6] if o[6]
	 		outp = fromOtherModule(c,params)
	 		return outp
	 	else
	 		msg = "Expected command : " + CheckoutOpt
	 		return msg
	 	end	
	 elsif c=="commit"
	 	o = fc.match CommitRe
	 	if o
	 		params = Hash.new
	 		params["add"] = true if o[2]
	 		params["msg"] = o[5] if o[4] and o[5]
	 		if o[6]
	 			files = o[6].split(" ")
	 			files.each_with_index{|file,i| params[("file"+(i+1).to_s)] = file }
	 		end
	 		outp = fromOtherModule(c,params)
	 		return outp
	 	else
	 		msg = "Expected command : " + CommitOpt
	 		return msg
	 	end	
	 elsif c=="branch"
	 	o = fc.match BranchRe
	 	if o
	 		params = Hash.new
	 		params["all"] = true if o[2]
	 		params["delete"] = true if o[5]
	 		params["branch"] = o[6] if o[6]
	 		outp = fromOtherModule(c,params)
	 		return outp
	 	else
	 		msg = "Expected command : " + BranchOpt
	 		return msg
	 	end	
	 elsif c=="merge"
	 	o = fc.match MergeRe
	 	if o
	 		params = Hash.new
	 		params["branch"] = o[2] if o[2]
	 		outp = fromOtherModule(c,params)
	 		return outp
	 	else
	 		msg = "Expected command : " + MergeOpt
	 		return msg
	 	end	
	 elsif c=="push"
	 	o = fc.match PushRe
	 	if o
	 		params = Hash.new
	 		params["remote"] = o[2] if o[2]
	 		params["branch"] = o[4] if o[4]
	 		outp = fromOtherModule(c,params)
	 		return outp
	 	else
	 		msg = "Expected command : " + PushOpt
	 		return msg
	 	end	
	 elsif c=="pull"
	 	o = fc.match PullRe
	 	if o
	 		params = Hash.new
	 		params["remote"] = o[2] if o[2]
	 		params["branch"] = o[4] if o[4]
	 		outp = fromOtherModule(c,params)
	 		return outp
	 	else
	 		msg = "Expected command : " + PullOpt
	 		return msg
	 	end	
	 elsif c=="status"
	 	o = fc.match StatusRe
	 	if o
	 		outp = fromOtherModule(c,params)
	 		return outp
	 	else
	 		msg = "Expected command : " + StatusOpt
	 		return msg
	 	end	
	 
	 elsif c=="clone"
	 	o = fc.match CloneRe
	 	if o
	 		params = Hash.new
	 		params["repository"] = o[2] if o[2]
	 		params["directory"] = o[5] if o[5]
	 		outp = fromOtherModule(c,params)
	 		return outp
	 	else
	 		msg = "Expected command : " + CloneOpt
	 		return msg
	 	end	
	 	elsif c=="diff"
	 	o = fc.match DiffRe
	 	if o
	 		params = Hash.new
	 		params["commit1"] = o[2] if o[2]
	 		params["commit2"] = o[4] if o[4]
	 		outp = fromOtherModule(c,params)
	 		return outp
	 	else
	 		msg = "Expected command : " + DiffOpt
	 		return msg
	 	end	
	 	elsif c=="help"
	 	`cat help.txt`
	 	end
	end
end

#Uncomment the below line to run this program
UserInterface.new.main