#This class contains the implementation of the user interface. 
#The implementation is limited to checking the basic commands only. The options of the commands
#are not included yet. 

class UserInterface
	#Used as a command starting keyword, just as 'git' in GitHub
	Start_keyword = "vcs"
	
	#Keywords used to exit the application. Any of the one can be used
	End_Keywords = ["quit","q","exit","end"]
	
	#List of valid commands. This list is used to compare with user's input
	Valid_Commands = ["init", "add", "checkout", "commit", "branch", "merge", "push", "pull", "status"]

	#This is the original 'main' method. This method scans for the user input. 
	#A new 'main' method has been defined for testing purpose that takes parameterized input. 
	#def main
	#	puts "Welcome to DVCS!"
	#	$stdin.each_line do |line|
    #		output = parseCommand(line)
    #		displayResult(output)
  	#	end
	#end
	
	#This method has been defined for testing purpose. It takes parameterized input.
	def main(input)
		#puts "Welcome to DVCS!"
    	output = parseCommand(input)
    	displayResult(output)
	end
	
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
				output = fromOtherModule(c) 
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
		#puts output
		output
	end
	
	#This is a temporary method that is acting as a method from another module. It is created for testing purpose.
	def fromOtherModule(c)
		msg = "'" + c + "' executed!"
		return msg
	end
end

#Uncomment the below line to run this program
#UserInterface.new.main("vcs init")