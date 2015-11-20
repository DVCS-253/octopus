require 'digest/sha2'
require 'json'

class Revlog

	
	# Initializes this instance along
	# with it's own hash table
	def initialize (filename = nil)
		@file_table = (filename == nil ? Hash.new : JSON.load(File.open(filename)))
		JSON.dump(@file_table, File.open('revlog.json', 'w'))
	end


	# Stores the specified file in a
	# hash table {file_id => file}
	# Parameters:
	# file:: file to be hashed
	# Returns:
	# file_id:: id of the hashed file
	def add_file (contents)
		#generate hash for file contents
		file_id = Digest::SHA2.hexdigest(contents)
		@file_table[file_id.to_sym] = contents 			#store file
		JSON.dump(@file_table, File.open('revlog.json', 'w')) #update hashfile
		return file_id
	end

	# Retrieves the file associated with
	# the specified file_id from the
	# hash table {file_id => file}
	# Parameters:
	# file_id:: file_id used for retrieval
	# Returns:
	# contents:: the contents retrieved from file
	def get_file (file_id)
		raise "Revlog Error: No such file" if @file_table[file_id.to_sym] == nil #if trying to get a nonexistant file
		return @file_table[file_id.to_sym]
	end

	# Deletes the file associated with
	# the specified file_id from the
	# hash table {file_id => file}
	# Parameters:
	# file_id:: file_id used for retrieval
	# Returns:
	# exit_code:: 0 if exited successfully
	def delete_file (file_id)
		raise "Revlog Error: No such file" if @file_table[file_id.to_sym] == nil	#if trying to delete a nonexistant file
		@file_table[file_id.to_sym] = nil
		JSON.dump(@file_table, File.open('revlog.json', 'w')) #update file
		return 0
	end

	def diff_files(file_id1, file_id2)
		file1 = get_file(file_id1)
		file2 = get_file(file_id2)
		file1 = file1.lines
		file2 = file2.lines

		return ((file1 - file2) + (file2-file1))
	end

	def merge(file_id1, file_id2, ancestor_id = nil)
		file1 = get_file(file_id1)
		file2 = get_file(file_id2)

		if ancestor_id == nil
			return add_file(merge_without_ancestor(file1, file2))
		end

		ancestor_file = get_file(ancestor_id)

		#keep files as list
		files = [ancestor_file.lines, file1.lines, file2.lines]
		#keep conflict output as list
		conflict_data = ["|"*8 + " base","<"*8 + " ours", ">"*8 + " theirs"]

		merged = ""
		loop do
			lines = files.map {|file| file.shift unless file.empty?}

			#helper funcs
			#writes to merged and updates line info
			write_merge = lambda { |i|
				while (lines[i] != lines[0])
					merged << lines[i]
					files[i].empty? ? break : lines[i] = files[i].shift
				end }
			#writes conflict tag to merged
			conflict_write = lambda { |i| merged << conflict_data[i] << "\n"}

			puts lines #print

			if lines[0] != lines[1] and lines[1] == lines[2]	#same extra lines files 1 & 2
				puts "1&2" #print
				while lines[1] == lines[2] and lines[1] != lines[0]
					merged << lines[1]
					lines[1] = files[1].shift unless files[1].empty?
					lines[2] = files[2].shift unless files[2].empty?
					break if files[1].empty? and files[2].empty?
				end
				break if files.all? {|file| file.empty?}
			end

			if lines.all? {|line| line == lines[0]} #no change
				puts "no" #print
			elsif lines[2] == lines[0] 				#extra lines file 1
				puts "file 1" #print
				write_merge.call(1)
			elsif lines[1] == lines[0] 				#extra lines file 2
				puts "file 2" #print
				write_merge.call(2)
			else 									#conflict
				puts "con" #print
				conflict_write.call(1)
				write_merge.call(1)
				merged << "="*8 << "\n"
				write_merge.call(2)
				conflict_write.call(2)
			end #End if
			break if files.all? {|file| file.empty?}
			merged << lines[0]
			puts "" #print
		end #End loop do
		return add_file(merged)
	end #End merge

	def merge_without_ancestor(file1, file2)
		#keep files as hash
		files = {1 => file1.lines, 2 => file2.lines}
		#hash of file lines, for each file
		file_lines = {1 => Hash.new(false), 2 => Hash.new(false)}

		#initialize hash
		files.each {|i, file|
			file_lines[i][nil] = true
			file.each {|line| file_lines[i][line] = true}}

		#keep conflict outputs as hash
		conflict_data = {1 => "<"*8 + " ours", 2 => ">"*8 + " theirs"}

		merged = ""
		# puts "------" #print
		loop do
			lines = files.map {|i, file| [i, file.shift] unless file.empty?}.delete_if {|x| x ==nil}
			lines = lines.to_h

			#helper funcs

			#writes to merged and updates line info and line hash
			write_merge = lambda { |i|
				while (!file_lines[~i+4][lines[i]])
					merged << lines[i]
					file_lines[i][lines[i]] = false
					files[i].empty? ? break : lines[i] = files[i].shift
				end }
			#writes conflict tag to merged
			conflict_write = lambda { |i| merged << conflict_data[i] << "\n"}

			# puts lines #print

			if(lines[1] == lines[2])		#no change
				# puts "no" #print
				file_lines.each {|i, file_table| file_table[lines[i]] = false}
			elsif(file_lines[1][lines[2]])	#extra lines file 1
				# puts "file 1" #print
				write_merge.call(1)
			elsif(file_lines[2][lines[1]])	#extra lines file 2
				# puts "file 2" #print
				write_merge.call(2)
			else							#conflict
				# puts "con" #print
				conflict_write.call(1)
				write_merge.call(1)
				merged << "="*8 << "\n"
				write_merge.call(2)
				conflict_write.call(2)
			end #End if
			# puts "-" #print
			merged << lines[1] if lines[1] == lines[2]
			break if files.all? {|i, file| file.empty?}
		end #End loop do

		return merged
	end #End merge_without_ancestor


end