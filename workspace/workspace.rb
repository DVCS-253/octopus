require 'fileutils'
#require_relative 'ReLog'
#require_relative 'Repos'

class Workspace


	def init
		Dir.mkdir('.octopus')
		Dir.mkdir('.octopus/revlog')
		Dir.mkdir('.octopus/repo')
		Dir.mkdir('.octopus/communication')
	end


	def check_out_snapshot(snapshot_id)
		workspace = '.octopus/'
		snapshot = Repos.restore_snapshot(snapshot_id)			
		file_hash = snapshot.repos_hash
                file_hash.each do |key, value|
                        path = key
			hash = value
                        content = RevLog.get_file(hash)	
			#how to duild a directory
			
			Dir.mkdir(directory_name) unless File.exists?(directory_name)
			
                        File.write(workspace + path, content)
                end
	end


	def clean
		all_files = Dir.glob('.octopus/*')
		all_files.each do |f|
			if f != '.octopus/revlog' and f != '.octopus/repo' and f != '.octopus/communication'
				FileUtils.rm_rf(f)
			end
		end	
		#head = Pepos.get_head()  						###Original implementation!!!
		#check_out_snapshot(head)						###Original implementation!!!
		check_out_snapshot(1)							#for testing
		return 0
	end

	def check_out(branch)
		#head = Repos.get_head(branch)			###Original implementation!!!
		#check_out_snapshot(head)			###Original implementation!!!

		check_out_snapshot(1) 				#for testing
		return 0	
	end



		
	def commit(files = nil)
		workspace = '.octopus/'
		results = {}
		if files == nil
			all_files = Dir.glob('.octopus/*')
			all_files.each do |f|
				if f != '.octopus/revlog' and f != '.octopus/repo' and f != '.octopus/communication'
					#results[f] = Revlog.hash(f)		###Original implementation!!!
					results[f] = 1				#for testing
				end
			end
			#snapshot_id = Repos.make_snapshot(results) 	###Original implementation!!!
			#Repos.update_head(snapshot_id)			###Original implementation!!!
			#return 0  					###Original implementation!!!
			return results 					#for testing
		end
		if files.is_a?(Array)
			files.each do |f|
				#results[f] = Revlog.hash(f)		###Original implementation!!!
				results[f] = 1				#for testing
			end
		else
			#results[files] = Revlog.hash(files)		###Original implementation!!!
			results[files] = 1				#for testing
		end
		#head = Repos.get_head()						###Original implementation!!!
		#current = Repos.restore_snapshot(head)					###Original implementation!!!
		#file_lst = current.file_lst()						###Original implementation!!!	
		file_lst = ['Test1.txt', 'Test2.txt', 'Test3.txt']			#for testing
		file_hash = {'Test1.txt' => 2, 'Test2.txt' => 3, 'Test3.txt' => 4} 	#for testing
		file_lst.each do |f|
			if not results.has_key?(f)
				results[workspace + f] = file_hash[f]
			end
		end
		#snapshot_id = Repost.make_snapshot(results)	###Original implementation!!!
		#Repost.update_head(snapshot_id)		###Original implementation!!!
		#return 1					###Original implementation!!!
		return results 					#for testing
	end



	def share_value(hash, v)
		flag = false
		hash.each do |key, value|
			return key if value == v
		end
		return false
	end



	def status()
		add = []
		delete = []
		update = []
		rename = []
		#head = Repos.get_head(branch)						###Original implementation!!!
		#snapshot = Repos.restore_snapshot(head)				###Original implementation!!!
		#file_lst = snapshot.file_list()					###Original implementation!!!
		#file_hash = snapshot.file_hash()					###Original implementation!!!
	
		file_lst = ['.octopus/Test1.txt', '.octopus/test2.txt', '.octopus/Test3.txt']				#for testing
		file_hash = {'.octopus/Test1.txt' => 1, '.octopus/test2.txt' => 2, '.octopus/Test3.txt' => 3} 		#for testing

		workspace_files = []
		all_files = Dir.glob('.octopus/*')
		all_files.each do |f|
			if f != '.octopus/revlog' and f != '.octopus/repo' and f != '.octopus/communication'
				workspace_files.push(f)
			end
		end
		#workspace_hash = {}							###Original implementation!!!
		#workspace_files.each do |f|						###Original implementation!!!
		#	workspace_hash[f] = Revlog.hash(f)				###Original implementation!!!
		#end									###Original implementation!!!
		workspace_hash = {'.octopus/test1.txt' => 3, '.octopus/test2.txt' => 4, '.octopus/est3.txt' => 5}	#for testing 


		workspace_files.each do |f|
			if file_hash.has_key?(f)
				if file_hash[f] != workspace_hash[f]
					update.push(f)
				end
			else
				if not share_value(file_hash, workspace_hash[f])
					add.push(f)
				end
			end
		end
		file_lst.each do |f|
			if not workspace_hash.has_key?(f)
				new_name = share_value(workspace_hash, file_hash[f])
				if new_name
					rename.push(f + ' => ' + new_name)
				else
					delete.push(f)
				end
			end
		end
		return add, delete, update, rename
	end

end
