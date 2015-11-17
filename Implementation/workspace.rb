require 'fileutils'

class Workspace

	def clean
		#Remove all the files in workspace
		workspace = './*'
		FileUtils.rm_rf(workspace)
		#call Repos.get_head() to get name of latest branch
		current = Repos.get_head().name
		#check out the lastest branch
		check_out(current)
	end


	def commit(files = nil)
		results = []
		if files == nil
			all_file = Dir["**/*"]
			all_file.each do |f|
				results.push((f, Revlog.hash(f)))
			end
		elsif files.is_a?(Array)
			files.each do |f|
				results.push((f, Revlog.hash(f)))
			end
		else
			results.push((f, Revlog.hash(f)))
		end
		current = Repos.last_snapshot()
		current_files = last_snapshot.file_list()
		current_files.each do |f|
			if not results.contains(f)
				results.push(f)
			end
		end
		Repos.creat_snapshot(results)
	end

	
	def check_out(files = branch)
		if files.is_a?(Array)
			files.each do |f|
				path, hash = f
				content = RevLog.get_file(hash)
				writeFile(path,content)
			end
		else
			branch = Repos.getBranch(list_file)
			files = branch.last_snapshot()
			files.each do |f|
				path, hash = f
				content = RevLog.get_file(hash) 
				writeFile(path,content)
			end
		end
	end


	def status()
		add = []
		delete = []
		update = [] 
		current = Repos.last_snapshot()
		current_files = last_snapshot.file_list()
		current_path = []
		current_hash = []
		current_files.each do |f|
			path, hash = f
			current_path.push(path)
			current_hash.push(hash)
		end
		workspace_files = Dir.glob('.')
		workspace_files.each do |f|
			if not current_files.contains(f)
				add.push(f)
			else
				if not current_hash.contains(RevLog.hash(f))
					update.push(f)
				end
			end
		end
		current_files.each do |f|
			if not workspace_files.contains(f)
				delete.push(f)
			end
		end
		return add, delete, update
	end

end
