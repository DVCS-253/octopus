require 'digest/sha2'
require 'json'

class Revlog
	@file_table = Hash.new # Hash table to store all file contents
	@json_file = '.octopus/revlog/revlog.json' # Json file where @file_table is stored

	class << Revlog


		# Load new file table
		def load_table (filename)
			new_table = File.open(filename)
			@file_table = JSON.load(new_table)
			new_table.close
		end


		# Stores the specified file in a
		# hash table {file_id => file_contents}
		# Parameters:
		# contents:: file_contents to be hashed
		# Returns:
		# string file_id:: id of the hashed contents
		def add_file (contents)
			#generate hash for file contents
			file_id = Digest::SHA2.hexdigest(contents)
			@file_table[file_id.to_sym] = contents	#store file
			database = File.open(@json_file, 'w')
			JSON.dump(@file_table, database) #update hashfile
			database.close
			return file_id
		end

		# Retrieves the file associated with
		# the specified file_id from the
		# hash table {file_id => file_contents}
		# Parameters:
		# file_id:: file_id used for retrieval
		# Returns:
		# string contents:: the contents retrieved from file_id
		def get_file (file_id)
			raise "Revlog Error: No such file" if @file_table[file_id.to_sym] == nil #if trying to get a nonexistant file
			return @file_table[file_id.to_sym]
		end

		# Deletes the file associated with
		# the specified file_id from the
		# hash table {file_id => file_contents}
		# Parameters:
		# file_id:: file_id used for retrieval
		# Returns:
		# int exit_code:: 0 if exited successfully
		def delete_file (file_id)
			raise "Revlog Error: No such file" if @file_table[file_id.to_sym] == nil	#if trying to delete a nonexistant file
			@file_table[file_id.to_sym] = nil
			database = File.open(@json_file, 'w')
			JSON.dump(@file_table, database) #update hashfile
			database.close
			return 0
		end

		# Finds the differences between
		# two files, specified by ids
		# Parameters:
		# file_id1:: file_id for first file
		# file_id2:: file_id for second file
		# Returns:
		# array diffs:: list of differences by line
		def diff_files(file_id1, file_id2)
			file1 = get_file(file_id1)
			file2 = get_file(file_id2)
			file1 = file1.lines
			file2 = file2.lines

			return ((file1 - file2) + (file2-file1))
		end

		# Merges two files, returning
		# the id of a file which is
		# either the successful merge
		# or the conflict file
		# hash table {file_id => file}
		# Parameters:
		# file_id1:: file_id for first file
		# file_id2:: file_id for second file
		# Returns:
		# string file_id:: id of the merged file
		def merge(file_id1, file_id2)
			file1 = get_file(file_id1)
			file2 = get_file(file_id2)

			#files in this method are actually just
			#long strings of file content

			#keep files as hash
			files = {1 => file1.lines, 2 => file2.lines}

			#hash of file lines, for each file
			file_lines = {1 => Hash.new {|h, k| h[k]=[]}, 2 => Hash.new {|h, k| h[k]=[]}}
			#hash of current line #, for each file
			curr_linenos = {1 => 0, 2 => 0}

			#initialize hash
			files.each {|i, file|
				file_lines[i][nil] = [file.length]
				file.each_with_index {|line, lineno| file_lines[i][line].push(lineno)}}

			#keep conflict outputs as hash
			conflict_data = {1 => "<"*8 + " ours", 2 => ">"*8 + " theirs"}

			merged = "" #output string
			loop do
				#initialize lines
				lines = files.map {|i, file| 
							curr_linenos[i] += 1 unless file.empty?
							[i, file.shift] unless file.empty?
							}.delete_if {|x| x ==nil}
				lines = lines.to_h

				####################
				# Helper Functions #
				####################
					# => ~i+4 is equivilant to:
					# => --- 2 if i == 1
					# => --- 1 if i == 2

				shared_line = lambda { |i| #does lines[i] appear later on in file[~i+4]
					return file_lines[~i+4][lines[i]].any? {|lineno| lineno >= curr_linenos[~i+4]}
				}
				line_diff = lambda { |i| #how far is lines[i] from curr_linenos[~i+4] in file[~i+4]
					return file_lines[~i+4][lines[i]].min_by {|lineno|
						lineno >= curr_linenos[~i+4] ? lineno - curr_linenos[~i+4] : files[~i+4].length}
				}
				inc = lambda { |i| #update line and lineno
					lines[i] = files[i].shift
					curr_linenos[i] += 1
				}
				write_str = lambda { |i, str = merged, con = false| #writes to str and updates line info and line hash
					while ((!shared_line.call(i) or !con) and lines[i] != lines[~i+4])
						str << lines[i]
						break if files[i].empty?
						inc.call(i)
					end
				}
				conflict_write = lambda { #writes conflicts to merged
					buffer = {1 => "", 2 => ""}
					get_next_shared = lambda { #read and fill buffers until next non-newline shared line
						loop do
							write_str.call(1, buffer[1], true)
							write_str.call(2, buffer[2], true)
							break unless lines.all? {|i, line| line == "\n"}
							while lines.all? {|i, line| line == "\n"}
								buffer[1] << lines[1]
								buffer[2] << lines[2]
								inc.call(1)
								inc.call(2)
							end
						end
					}
					get_next_shared.call
					if (shared_line.call(2) and shared_line.call(1))
						to_inc = line_diff.call(2) < line_diff.call(1) ? 1 : 2
						while lines[1] != lines[2]
							buffer[to_inc] << lines[to_inc]
							inc.call(to_inc)
							write_str.call(to_inc, buffer[to_inc], true)
							get_next_shared.call if lines.all? {|i, line| line == "\n"}
							to_inc = ~to_inc+4 if lines[~to_inc+4] == "\n"
						end
					end
					merged << conflict_data[1] << "\n"
					merged << buffer[1]
					merged << "="*8 << "\n"
					merged << buffer[2]
					merged << conflict_data[2] << "\n"
				}

				##############
				# Loop Logic #
				##############

				if(lines[1] == lines[2])	#no change
				elsif(shared_line.call(2) and shared_line.call(1)) #mutually occuring lines
					to_inc = line_diff.call(2) < line_diff.call(1) ? 1 : 2
					while(lines[to_inc]!=lines[~to_inc+4])
						merged << lines[to_inc]
						lines[to_inc] = files[to_inc].shift
						curr_linenos[to_inc] += 1
					end
				elsif(shared_line.call(2))	#extra lines file 1
					write_str.call(1)
				elsif(shared_line.call(1))	#extra lines file 2
					write_str.call(2)
				else						#conflict
					conflict_write.call
				end #End if
				merged << lines[1] if lines[1] == lines[2]
				break if files.all? {|i, file| file.empty?}
			end #End loop do
			return add_file(merged)
		end #End merge
	end

end #End class Revlog