require 'fileutils'
require_relative 'ReLog'
require_relative 'Repos'

class Workspace

	#intialize folders for Repos and RevLog	
	#create .octopus/
	#create .octopus/revlog
	#create .octopus/repo
	#create .octopus/communication
	def init
		Dir.mkdir('.octopus')
		Dir.mkdir('.octopus/revlog')
		Dir.mkdir('.octopus/repo')
		Dir.mkdir('.octopus/communication')
	end


	def check_out_snapshot(snapshot)
                file_lst = snapshot.file_lst()
                file_lst.each do |f|
                        path, hash = f
                        content = RevLog.get_file(hash)
                        writeFile(path, content)
                end
	end


	def clean
		all_files = Dir.glob('.octopus/*')
		all_files.each do |f|
			if f != '.octopus/revlog' and f != '.octopus/repo' and f != '.octopus/communication'
				FileUtils.rm_rf(f)
			end
		end	
		head = Pepos.get_head()
		current_snapshot = Repos.restore_snapshot(head)	
		check_out(current_snapshot)
		return 0
	end


	
	def commit(files = nil)
		results = []
		if files == nil
			all_files = Dir.glob('.')
			all_files.each do |f|
				results.push((f, Revlog.hash(f)))
			end
			snapshot_id = Repos.make_snapshot(results)
			Repos.update_head(snapshot_id)	
			return 0
		end


		if files.is_a?(Array)
			files.each do |f|
				results.push((f, Revlog.hash(f)))
			end
		else
			results.push(files, Revlog.hash(files))
		end
		
		head = Repos.get_head()
		current = Repos.restore_snapshot(head)
		current_files = current.file_lst()		
		
		current_files.each do |f|
			if not results.contains(f)
				results.push(f)
			end
		end
		snapshot_id = Repost.make_snapshot(results)
		Repost.update_head(snapshot_id)
		return 1
	end


	def check_out(branch)
		head = Repos.get_head(branch)
		snapshot = Repost.restore_snapshot(head)
		check_out_snapshot(snapshot)
		return 0	
	end


	def status()
		add = []
		delete = []
		update = []
		rename = []
		head = Repos.get_head(branch)
		snapshot = Repos.restore_snapshot(head)
		current_files = snapshot.file_lst()	
		current_path = []
		current_hash = []
		current_files.each do |f|
			path, hash = f
			current_path.push(path)
			current_hash.push(hash)
		end
		workspace_files = Dir.glob('.')
		workspace_hash = []
		workspace_files.each do |f|
			workspace_hash.push(RevLog.hash(f))
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
				if not workspace_hash.contains(RevLog.hash(f))
					delete.push(f)
				else
					rename.push(f)
				end
			end
		end
		return add, delete, update, rename
	end

end
