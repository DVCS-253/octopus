class UserInterface
	Start_keyword = "vcs"
	End_Keywords = ["quit","q","exit","end"]
	Valid_Commands = ["init", "add", "checkout", "commit", "branch", "merge", "push", "pull", "status"]

	#def main
	#	puts "Welcome to DVCS!"
	#	$stdin.each_line do |line|
    #		output = parseCommand(line)
    #		displayResult(output)
  	#	end
	#end
	
	def main(input)
		#puts "Welcome to DVCS!"
    	output = parseCommand(input)
    	displayResult(output)
	end
	
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
	
	def displayResult(output)
		#puts output
		output
	end
	
	def fromOtherModule(c)
		msg = "'" + c + "' executed!"
		return msg
	end
end

#UserInterface.new.main()