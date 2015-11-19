class Revlog

	
	# Initializes this instance along
	# with it's own hash table
	def initialize
		@file_table = Hash.new 						#hash table, unique for each instance
	end


	# Stores the specified file in a
	# hash table {file_id => file}
	# Parameters:
	# file:: file to be hashed
	# Returns:
	# file_id:: id of the hashed file
	def add_file (file)
		file_id = Random.new_seed
		while(@file_table.key?(file_id))			#create new file ID, repeating if a duplicate is created (though this is extremely unlikely)
			file_id = Random.new_seed
		end
		@file_table[file_id] = file 				#hash file
		return file_id
	end

	# Retrieves the file associated with
	# the specified file_id from the
	# hash table {file_id => file}
	# Parameters:
	# file_id:: file_id used for retrieval
	# Returns:
	# file:: the file retrieved
	def get_file (file_id)
		return @file_table[file_id]
	end

	# Deletes the file associated with
	# the specified file_id from the
	# hash table {file_id => file}
	# Parameters:
	# file_id:: file_id used for retrieval
	# Returns:
	# exit_code:: 0 if exited successfully
	def delete_file (file_id)
		if	@file_table.delete(file_id) == nil	#if trying to delete a nonexistant file
			puts "#{file_id} does not exist"
			return 1
		end
		return 0
	end

	def diff_files(file_id1, file_id2)
		file1 = get_file(file_id1)
		file2 = get_file(file_id2)
		if file1 == nil or file2 == nil
			raise "No such file"
		end
		file1 = file1.lines
		file2 = file2.lines

		return ((file1 - file2) + (file2-file1)).join("")
	end

	def merge(file_id1, file_id2, ancestor_id = nil)
		# file1 = get_file(file_id1)
		# file2 = get_file(file_id2)
		file1 = File.open(File.basename(file_id1)) #Remove
		file2 = File.open(File.basename(file_id2)) #Remove

		if file1 == nil or file2 == nil
			raise "No such file"
		end

		if ancestor_id == nil
			return add_file(merge_without_ancestor(file1, file2))
		end

		# ancestor_file = get_file(ancestor_id)
		ancestor_file = File.open(File.basename(ancestor_id)) #Remove

		#keep files as list
		files = [ancestor_file, file1, file2]
		#keep conflict output as list
		filenames = [File.basename(ancestor_file),"<"*8 + File.basename(file1), ">"*8 + File.basename(file2)]

		merged = File.new("merging", "w")
		loop do
			lines = files.map {|file| file.readline unless file.eof?}

			#helper funcs
			#writes to merged and updates line info
			write_merge = lambda { |i|
				while (lines[i] != lines[0])
					merged.puts lines[i]
					files[i].eof? ? break : lines[i] = files[i].readline
				end }
			#writes conflict tag to merged
			conflict_write = lambda { |i| merged.puts filenames[i]}

			# puts lines #print

			if lines.all? {|line| line == lines[0]} #no change
				# puts "no" #print
			elsif lines[2] == lines[0] 				#extra lines file 1
				# puts "file 1" #print
				write_merge.call(1)
			elsif lines[1] == lines[0] 				#extra lines file 2
				# puts "file 2" #print
				write_merge.call(2)
			else 									#conflict
				# puts "con" #print
				conflict_write.call(1)
				write_merge.call(1)
				merged.puts "="*8
				write_merge.call(2)
				conflict_write.call(2)
			end
			break if files.all? {|file| file.eof?}
			merged.puts lines[0]
			# puts "-" #print
		end
		return add_file(merged)
	end

	def merge_without_ancestor(file1, file2)
		#keep files as hash
		files = {1 => file1, 2 => file2}
		#hash of file lines, for each file
		file_lines = {1 => Hash.new(false), 2 => Hash.new(false)}

		#initialize hash
		files.each {|i, file|
			file_lines[i][nil] = true
			file.each {|line| file_lines[i][line] = true}}
		#reset files
		files.each {|i, file| file.rewind}

		#keep conflict outputs as hash
		filenames = {1 => "<"*8 + File.basename(file1), 2 => ">"*8 + File.basename(file2)}

		merged = File.new("merged", "w")
		# puts "------" #print
		loop do
			lines = files.map {|i, file| [i, file.readline] unless file.eof?}.delete_if {|x| x ==nil}
			lines = lines.to_h

			#helper funcs

			#writes to merged and updates line info and line hash
			write_merge = lambda { |i|
				while (!file_lines[~i+4][lines[i]])
					merged.puts lines[i]
					file_lines[i][lines[i]] = false
					files[i].eof? ? break : lines[i] = files[i].readline
				end }
			#writes conflict tag to merged
			conflict_write = lambda { |i| merged.puts filenames[i]}

			# puts lines #print

			if(lines[1] == lines[2])		#no change
				# puts "no" #print
				file_lines.each {|i, file_table| file_table[lines[i]] = false}
			elsif(file_lines[1][lines[2]])	#extra lines file 1
				write_merge.call(1)
				# puts "file 1" #print
			elsif(file_lines[2][lines[1]])	#extra lines file 2
				# puts "file 2" #print
				write_merge.call(2)
			else							#conflict
				# puts "con" #print
				conflict_write.call(1)
				write_merge.call(1)
				merged.puts "="*8 
				write_merge.call(2)
				conflict_write.call(2)
			end
			# puts "-" #print
			break if files.all? {|i, file| file.eof?}
			merged.puts lines[1]
		end
		return merged
	end

	def test()
		a = File.open("file1.txt")
		b = File.open("file2.txt")
		c = File.open("ances.txt")
		a.close
		b.close
		c.close
		merge(a,b,c)
		merge(a,b)
	end
end

x = Revlog.new
x.test