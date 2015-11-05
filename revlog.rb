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
		if	@file_table.delete(file_id) == nil
			puts "#{file_id} does not exist"
			return 1
		end
		return 0
	end

end