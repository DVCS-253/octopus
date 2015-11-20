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
		#snapshot = Repos.restore_snapshot(snapshot_id)				###Original implementation!!!
                #file_lst = snapshot.file_lst()						###Original implementation!!!
		#file_hash = snapshot.file_hash()					###Original implementation!!!
		file_lst = ['test1.txt', 'test2.txt', 'text3.txt']			#for testing
		file_hash = {'test1.txt' => 1, 'test2.txt' => 1, 'test3.txt' => 1} 	#for testing	
                file_lst.each do |f|
                        path = f
			hash = file_hash[f]
                        #content = RevLog.get_file(hash)				###Original implementation!!!
			content = hash  						#for testing
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

		check_out_snapshot(1) #for testing
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
		#file_lst = current.file_lst()					###Original implementation!!!	
		file_lst = ['Test1.txt', 'Test2.txt', 'Test3.txt']
		file_hash = {'Test1.txt' => 2, 'Test2.txt' => 3, 'Test3.txt' => 4} 	
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




	def status()
		add = []
		delete = []
		update = []
		rename = []
		#head = Repos.get_head(branch)						###Original implementation!!!
		#snapshot = Repos.restore_snapshot(head)				###Original implementation!!!
		#file_lst = snapshot.file_list()
		#file_hash = snapshot.file_hash()
	
		file_lst = ['test1.txt', 'test2.txt', 'text3.txt']
		file_hash = {'test1.txt' => 1, 'test2.txt' => 1, 'test3.txt' => 1} 	

		workspace_files = []
		all_files = Dir.glob('.octopus/*')
		all_files.each do |f|
			if f != '.octopus/revlog' and f != '.octopus/repo' and f != '.octopus/communication'
				workspace_files.push(f)
			end
		end
		workspace_hash = {}
		workspace_files.each do |f|
			#workspace_hash[f] = Revlog.hash(f)			###Original implementation!!!
			workspace_hash[f] = 1

			if file_hash.has_key?(f)
				if not file_hash[f] == workspace_hash[f]
					update.push[f]
				end
			else
				rename_flag = false
				file_hash.each do |g|
					if file_hash[g] = workspace_hahs[f]
						rename_flag = true
						break
					end
				end
				if rename_flag
					rename.push[f]
				else
					add.push[f]
				end
			end
		end
		file_hash.each do |f|
			if not workspace_files.hash_key?(f)
				rename_flag = false
				workspace_hash.each do |g|
					if file_hash[g] = workspace_hash[g]
						rename_flag = true
						break
					end
				end
				if rename_flag
					rename.push[f]
				else
					delete.push[f]
				end
			end
		end
		return add, delete, update, rename
	end

end
