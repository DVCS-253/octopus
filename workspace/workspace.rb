require 'fileutils'
require "#{File.dirname(__FILE__)}/../repo/repos.rb"
require "#{File.dirname(__FILE__)}/../revlog/revlog.rb"

class Workspace


	def init
		p "init"
		Dir.mkdir('.octopus')
		Dir.mkdir('.octopus/revlog')
		Dir.mkdir('.octopus/repo')
		Dir.mkdir('.octopus/communication')
	end

	#Given a file path, rebuild its dir
	#Note: the parameter needs to be a path of a file, not a path of a directory
	#Example: rebuild_dir('DVCS/test/test_case.rb')
	#Effect: directory "./DVCS/test/" will be set up, if already existed then do nothing
	def rebuild_dir(path)
		#split the path with file_seperator
		hierarchy = path.split('/')
		path = './'
		#ignore the file name 
		(0..hierarchy.length-2).each do |d|
			path = path + hierarchy[d] + '/'
			Dir.mkdir(path) if not File.directory?(path)
		end
	end


	#Remove all files and folders under workspace except for ./.octopus
	def clean
		all_files = Dir.glob('./*')
		all_files.each do |f|
			if f != './.octopus'
				FileUtils.rm_rf(f)
			end
		end	
	end
	

	#Given a snapshot id, copy the snapshot to the workspace
	def check_out_snapshot(snapshot_id)
		#clean the workspace first
		clean
		#obtian the snapshot object using retore_snapshot
		snapshot = Repos.restore_snapshot(snapshot_id)	
		#obtian the file_hash from the object		
		file_hash = snapshot.repos_hash
                file_hash.each do |path, hash|
			#rebuild the directory of the file
			rebuild_dir(path)
			#decode the content of a file
                        content = Revlog.get_file(hash)	
			#write content
                        File.write(path, content)
                end
	end


	#Given a file path, copy the file from current head snapshot	
	def check_out_file(path)
		#obtain the head snapshot
		head = Repos.get_head()
		snapshot = Repos.restore_snapshot(head)
		file_hash = snapshot.repos_hash
		#obtain the content of the file
		hash = file_hash[path]
		content = Revlog.get_file(hash)
		rebuild_dir(path)
		File.write(path, content)	
	end


	#checkout a branch or a file
	#input arg is a branch name or a file path
	def checkout(arg)
		#if branch name doesn't exist, ASSUME RETURN IS NIL
		head = Repos.get_head(arg)
		if head == nil
			#input is a file, checkout the file
			check_out_file(arg)
		else
			#input is a branch name, checkout the head snapshot
			check_out_snapshot(head)
		end
		return 0	
	end


	#Given a list of file, buil a hash table of them
	#key = path; value = content
	def build_hash(file_list)
		results = {}
		file_list.each do |path|
			content = File.read(path)
			results[path] = content
		end
		return results
	end


	#commit a list of file, a directory or a branch
	#list contains path of fiels, for example ['workspace/a.rb', 'repos/b.rb', 'test/c.rb']
	#directory needs to be a existed path, for example 'workspace' or 'workspace/test'
	def commit(arg = nil)
		results = {}
		#commit a branch
		if arg == nil
			#obtain a file list contains all files excpet for those under ./.octopus/
			all_files = Dir.glob('./**/*').select{ |e| File.file? e and (not e.include? '.octopus') }
			#build a hash table for the files
			results = build_hash(all_files)
			#make a new snapshot and update the head
			snapshot_id = Repos.make_snapshot(results)
			Repos.update_head(snapshot_id)
			return 0 
		end
		#commit a list of files
		if arg.is_a?(Array)
			arg.each do |f|
				path = './'+ f
				content = File.read(path)
				results[f] = content
			end
		#commit a directory
		elsif File.directory?('./' + arg)
			path = './' + arg
			all_files = Dir.glob('./' + arg + '/**/*').select{ |e| File.file?}
			results = build_hash(all_files)
		end

		#if commit a list or a directory, add last committed files 
		head = Repos.get_head()
		snapshot = Repos.restore_snapshot(head)
		file_hash = snapshot.repos_hash	
		file_hash.each do |path, hash|
			#add new files from last commit 
			if not results.has_key?(path)
				content = Revlog.get_file(hash)
				results[path] = content
			end
		end
		#make a new snapshot and update the head 
		snapshot_id = Repost.make_snapshot(results)
		Repost.update_head(snapshot_id)
		return 1			
	end



	#check if content exists in given hash table 
	#if yes, return its key
	#if no, return flase
	def appear(content_table, content)
		content_table.each do |path, value|
			return path if value == content
		end
		return false
	end



	#add: a file is added if this file exists in workspace and has a new name and new content
	#delete: a file is deleted if this file exists in last committed snapshot and no file in workspace share name and content with it
	#update: a file is updated if this file exists in last committed snapshot and a file with same name is workspace has different content with it 
	#rename: a file is renamed if this file exists in last committed snapshot and a file in workspace has same content but different name with it 
	def status()
		add = []
		delete = []
		update = []
		rename = []
		head = Repos.get_head(branch)	
		snapshot = Repos.restore_snapshot(head)	
		#file_content is a hashtable for files of last commit, key = path, value = content
		file_hash = snapshot.repos_hash	
		file_content = {}
		file_hash.each do |path|
			file_content[path] = Revlog.get_file(path)
		end
		#workspace_contetn is a hashtable for files in workspace, key = path, value = content
		workspace_files = Dir.glob('./**/*').select{ |e| File.file? e and (not e.include? '.octopus') }
		workspace_content = {}		
		workspace_files.each do |path|	
			workspace_content[path] = File.read(path)	
		end				
		#check every file in workspace
		workspace_content.each do |path, content|
			#if the name appears in last commit
			if file_content.has_key?(path)
				#if the content is changed, then it's updated
				if file_content[path] != content
					update.push(path)
				end	
			#if the name doesn't appear in last commit (could be added or renamed)
			else
				#if the content doesn't appers in last commit
				if not appear(file_content, content)
					add.push(path)
				end
			end
		end
		#check every file in last commit
		file_content.each do |path, content|
			#if a file in last commit doesn't appear in workspace, it could be deleted or renamed
			if not workspace_content.has_key?(path)
				#check if the content appears in workspace
				new_name = appear(workspace_content, content)
				#if the content appears in workspace, it's renamed
				if new_name
					rename.push(path + ' => ' + new_name)
				#else this file is deleted
				else
					delete.push(path)
				end
			end
		end
		return add, delete, update, rename
	end
end
