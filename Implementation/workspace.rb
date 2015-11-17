require 'fileutils'

class Workspace

	def clean
		#Remove all the files in workspace
		workspace = './'
		FileUtils.rm_rf(workspace)
		#call Repos.get_head() to get name of latest branch
		current = Repos.get_head()
		#check out the lastest branch
		check_out(current)
		#return exit code 0
		return 0
	end




	def commit(files = nil)
		exit_code = 0
		results = []
		#commit all files and directory in workspace
		if files == nil
			all_file = Dir.glob('.')
			all_file.each do |f|
				#store (file, hash_of_file) in a list
				results.push((f, Revlog.hash(f)))
			end
			#create a new snapshot
			Repos.make_snapshot(results)
			#commit whole project, return exit code 0
			return exit_code
		elsif files.is_a?(Array)
			#commit a list of files, return exit code 1
			exit_code = 1
			files.each do |f|
				results.push((f, Revlog.hash(f)))
			end
		else
			#commit a single file, return exit code 2
			exit_code = 2
			results.push((f, Revlog.hash(f)))
		end
		#add unchanged files from last snapshot
		current = Repos.last_snapshot()
		current_files = last_snapshot.file_list()
		current_files.each do |f|
			if not results.contains(f)
				results.push(f)
			end
		end
		#create a new snapshot
		Repos.make_snapshot(results)
	end



	
	def check_out(files = branch)
		#check out a list of files
		if files.is_a?(Array)
			files.each do |f|
				path, hash = f
				#using hash of a file to get the content
				content = RevLog.get_file(hash)
				#store the content in corresponding location
				writeFile(path,content)
			end
			return 1
		#check out a branch
		else
			#using the name of branch to get list of files
			branch = Repos.getBranch(files)
			files = branch.last_snapshot()
			files.each do |f|
				path, hash = f
				content = RevLog.get_file(hash) 
				writeFile(path,content)
			end
			return 2
		end
		return 0
	end




	def status()
		add = []
		delete = []
		update = []
		rename = [] 
		#obtain the latest snapshot
		current = Repos.last_snapshot()
		current_files = last_snapshot.file_list()
		current_path = []
		current_hash = []
		#obtian the name(path) and content(hash value) of files in last snapshot
		current_files.each do |f|
			path, hash = f
			current_path.push(path)
			current_hash.push(hash)
		end
		#obtian the names(path) of files in workspace 
		workspace_files = Dir.glob('.')
		workspace_hash = []
		workspace_files.each do |f|
			workspace_hash.push(RevLog.hash(f))
			#the files that don't appear in last snapshot are new added files
			if not current_files.contains(f)
				add.push(f)
			else
				#the files appear in last snapshot but have different hash are updated files
				if not current_hash.contains(RevLog.hash(f))
					update.push(f)
				end
			end
		end
		current_files.each do |f|
			#files appear in last snapshot but not in workspace
			if not workspace_files.contains(f)
				#if the hash of the file not in workspace neither, the file is deleted
				if not workspace_hash.contains(RevLog.hash(f))
					delete.push(f)
				#if the file content(hash) is in workspace the file is renamed
				else
					rename.push(f)
				end
			end
		end
		return add, delete, update
	end

end
