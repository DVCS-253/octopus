require 'fileutils'
require "#{File.dirname(__FILE__)}/../repo/repos.rb"
require "#{File.dirname(__FILE__)}/../revlog/revlog.rb"

class Workspace

	@@base_dir = '.octopus/base_dir'

	def init
		@repo_directory = Dir.pwd
		Dir.mkdir('.octopus')
		Dir.mkdir('.octopus/revlog')
		Dir.mkdir('.octopus/repo')
		Dir.mkdir('.octopus/communication')
		Repos.init
		File.open(@@base_dir, 'w'){ |f| f.write ("#{Dir.pwd}")}
		return "Initialized octopus repository"
	end

	#Given a file path, rebuild its dir
	#Note: the parameter needs to be a path of a file, not a path of a directory
	#Example: rebuild_dir('DVCS/test/test_case.rb')
	#Effect: directory "./DVCS/test/" will be set up, if already existed then do nothing
	def rebuild_dir(path)
		#split the path with file_seperator
		#ignore the file name 
		d = path.split("/")
		d.pop
		dpath = "/"+d.join("/")
		unless File.file?(dpath)
			unless File.directory?(dpath)
				FileUtils.mkdir(File.read('.octopus/base_dir') + dpath)
			end
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
		#obtain the snapshot object using retore_snapshot
		snapshot = Marshal.load(snapshot_id) # used to be load a file, but this is more efficient	
		#obtian the file_hash from the object		
		# puts "snapshot:"
		# puts snapshot
		# puts snapshot.branch_name
		# puts snapshot.commit_msg
		# puts snapshot.parent[0].repos_hash.to_a.inspect
		file_hash = snapshot.repos_hash
		# puts snapshot.repos_hash.to_a.inspect
        file_hash.each do |path, hash|
			#rebuild the directory of the file
			rebuild_dir(path)
			#decode the content of a file
	        content = Revlog.get_file(hash)	
			#write content
	        File.write(path, content)
	    end
	    Repos.set_current_branch(snapshot_id)
	    "Successfully checked out #{Repos.get_current_branch}"
	end

	def check_out_branch(branch_name)
		snapshot_ID = Repos.get_head(branch_name)
		check_out_snapshot(snapshot_ID)
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
		File.write(File.basename(path), content)	
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
	def commit(arg = nil, commit_msg = nil)
		#There has to be a message
		if commit_msg == nil
			return "Please include a commit message"	
		end

		results = {}
		#commit a branch
		# if arg == nil
		# 	#obtain a file list contains all files excpet for those under ./.octopus/
		# 	all_files = Dir.glob('./**/*').select{ |e| File.file? e and (not e.include? '.octopus') }
		# 	#build a hash table for the files
		# 	results = build_hash(all_files)
			#make a new snapshot and update the head
		# 	snapshot_id = Repos.make_snapshot(results, commit_msg)
		# 	Repos.update_head(snapshot_id)
		# 	return 0 
		# end
		#commit a list of files
		if arg.is_a?(Array)
			results = {}
			arg.each do |f|
				#commit a directory
				if File.directory?('./' + f)
					all_files = Dir.glob('./' + f + '/**/*').select{ |e| File.file?}
					results.merge!(build_hash(all_files))
				else
					content = File.read(f)
					results[f] = content
				end
			end
    	end

		#if commit a list or a directory, add last committed files 
		# head = Repos.get_head
		# snapshot = Repos.restore_snapshot(head)
		# file_hash = snapshot.repos_hash	
		# file_hash.each do |path, hash|
		# 	#add new files from last commit 
		# 	if not results.has_key?(path)
		# 		content = Revlog.get_file(hash)
		# 		results[path] = content
		# 	end
		# end
		#make a new snapshot and update the head 
		# p results.class
		snapshot_id = Repos.make_snapshot(results, commit_msg)
		# p "printing head" + snapshot_id
		# Repos.update_head(snapshot_id) <-- Repos does this
		if arg.size == 1
			return "1 file was commited"
		else
			return arg.size.to_s + " files were committed"
		end			
	end

	#check if content exists in given hash table 
	#if yes, return its key
	#if no, return flase
	#def appear(content_table, content)
	#	content_table.each do |path, value|
	#		return path if value == content
	#	end
	#	return false
	#end


	#new version of status
	#using commit time instead of file content
	def status
		uncommitted = []
		workspace_files = Dir.glob('./**/*').select{ |e| File.file? e and (not e.include? '.octopus') }
			
		workspace_files.each do |path|
			content = File.read(path)
			time = File.mtime(path).to_s
			file_id = Digest::SHA2.hexdigest(content + time)
			uncommitted.push(path) if Revlog.get_file(file_id) == 'Revlog: File not found'
		end		

		return uncommitted
	end



	#add: a file is added if this file exists in workspace and has a new name and new content
	#delete: a file is deleted if this file exists in last committed snapshot and no file in workspace share name and content with it
	#update: a file is updated if this file exists in last committed snapshot and a file with same name is workspace has different content with it 
	#rename: a file is renamed if this file exists in last committed snapshot and a file in workspace has same content but different name with it 
	
	#def status
	#	add = []
	#	delete = []
	#	update = []
	#	rename = []
	#	head = Repos.get_head	
	#	snapshot = Repos.restore_snapshot(head)	
	#	#file_content is a hashtable for files of last commit, key = path, value = content
	#	file_hash = snapshot.repos_hash	
	#	file_content = {}
	#	file_hash.each do |path|
	#		p path
	#		file_content[path] = Revlog.get_file(path[1])
	#	end
	#	#workspace_contetn is a hashtable for files in workspace, key = path, value = content
	#	workspace_files = Dir.glob('./**/*').select{ |e| File.file? e and (not e.include? '.octopus') }
	#	workspace_content = {}		
	#	workspace_files.each do |path|	
	#		workspace_content[path] = File.read(path)	
	#	end				
	#	#check every file in workspace
	#	workspace_content.each do |path, content|
	#		#if the name appears in last commit
	#		if file_content.has_key?(path)
	#			#if the content is changed, then it's updated
	#			if file_content[path] != content
	#				update.push(path)
	#			end	
	#		#if the name doesn't appear in last commit (could be added or renamed)
	#		else
	#			#if the content doesn't appers in last commit
	#			if not appear(file_content, content)
	#				add.push(path)
	#			end
	#		end
	#	end
	#	#check every file in last commit
	#	file_content.each do |path, content|
	#		#if a file in last commit doesn't appear in workspace, it could be deleted or renamed
	#		if not workspace_content.has_key?(path)
	#			#check if the content appears in workspace
	#			new_name = appear(workspace_content, content)
	#			#if the content appears in workspace, it's renamed
	#			if new_name
	#				rename.push(path + ' => ' + new_name)
	#			#else this file is deleted
	#			else
	#				delete.push(path)
	#			end
	#		end
	#	end
	#	return add, delete, update, rename
	#end
end
