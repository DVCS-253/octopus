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

	def merge(ancestor_id = nil, file_id1, file_id2)
		# file1 = get_file(file_id1)
		# file2 = get_file(file_id2)
		file1 = File.open(File.basename(file_id1)) #Remove
		file2 = File.open(File.basename(file_id2)) #Remove

		merged = File.new("merging", "w")
		if file1 == nil or file2 == nil
			raise "No such file"
		end

		if ancestor_id == nil
			return add_file(merge_without_ancestor(file1, file2))

		return add_file(merged)

	def merge_without_ancestor(file1, file2)
		file1_lines = Hash.new(false)
		file2_lines = Hash.new(false)

		file1.each_line {|line| file1_lines[line] = true}
		file2.each_line {|line| file2_lines[line] = true}

		filename1 = File.basename(file1)
		filename2 = File.basename(file2)

		file1.rewind
		file2.rewind

		#helper function
		write_merge = lambda do |merged, file, name, line, otherline, table|
			merged.puts ">>" + name
			while (line != otherline) and !file.eof?
				merged.puts "\t" + line
				line = file.readline
				table[line] = false
			end
		end

		while !file1.eof? and !file2.eof?
			line1 = file1.readline
			line2 = file2.readline
			if(line1 == line2)
				merged.puts line1
				file1_lines[line1] = false
				file2_lines[line2] = false
			elsif(file1_lines[line2])
				write_merge.call(merged, file1, filename1, line1, line2, file1_lines)
			elsif(file2Lines[line1])
				write_merge.call(merged, file2, filename2, line2, line1, file2_lines)
			else
				write_merge.call(merged, file1, filename1, line1, line2, file1_lines)
				write_merge.call(merged, file2, filename2, line2, line1, file2_lines)
			end
		end
		return merged
	end

	def test()
		a = File.new("file1.txt","w")
		b = File.new("file2.txt", "w")
		a.puts "first\nfile\nanarchy"
		b.puts "file\nanarchy\nNaNarchy"
		a.close
		b.close
		merge(0,a,b)
	end
end

x = Revlog.new
x.test