

require 'fileutils'

class Workspace

	def init
		Dir.mkdir('.octopus')
		Dir.mkdir('.octopus/revlog')
		Dir.mkdir('.octopus/repo')
		Dir.mkdir('.octopus/communication')
		#Repos.init
		return "Initialized octopus repository"
	end

	def rebuild_dir(path)
		hierarchy = path.split('/')
		path = './'
		(0..hierarchy.length-2).each do |d|
			path = path + hierarchy[d] + '/'
			Dir.mkdir(path) if not File.directory?(path)
		end
	end


	def clean
		all_files = Dir.glob('./*')
		all_files.each do |f|
			if f != './.octopus'
				FileUtils.rm_rf(f)
			end
		end	
	end
	

	def check_out_snapshot(snapshot_id)
		#clean
		#snapshot = Repos.restore_snapshot(snapshot_id)	
		#file_hash = snapshot.repos_hash
		file_hash = {"test1.txt"=>1, "test2.txt"=>2, "test3.txt"=>3} #testing
                file_hash.each do |path, hash|
			rebuild_dir(path)
                        #content = Revlog.get_file(hash) #testing	
			content = "test content"
                        File.write(path, content)
                end
	end


	def check_out_file(path)
		#head = Repos.get_head()
		#snapshot = Repos.restore_snapshot(head)
		#file_hash = snapshot.repos_hash
		#hash = file_hash[path]
		#content = Revlog.get_file(hash)
		path = "test1.txt"
		content = "test content"
		rebuild_dir(path)
		File.write(path, content)	
	end



	def checkout(arg)
		head = Repos.get_head(arg)
		if head == nil
			check_out_file(arg)
		else
			check_out_snapshot(head)
		end
		return 0	
	end



	def build_hash(file_list)
		results = {}
		file_list.each do |path|
			content = File.read(path)
			results[path] = content
		end
		return results
	end




	def commit(arg = nil, commit_msg = nil)
		if commit_msg == nil
			return "Please include a commit message"	
		end

		results = {}
		if arg == nil
			all_files = Dir.glob('./**/*').select{ |e| File.file? e and (not e.include? '.octopus') }
			results = build_hash(all_files)
			#snapshot_id = Repos.make_snapshot(results, commit_msg)
			#Repos.update_head(snapshot_id)
			return 0 
		end
		if arg.is_a?(Array)
			results = {}
			arg.each do |f|
				content = File.read(f)
				results[f] = content
			end
		elsif File.directory?('./' + arg)
			all_files = Dir.glob('./' + arg + '/**/*').select{ |e| File.file?}
			results = build_hash(all_files)
		end

		return results #testing

		#snapshot_id = Repos.make_snapshot(results, commit_msg)

		#if arg.size == 1
		#	return "1 file was commited"
		#else
		#	return arg.size.to_s + " files were committed"
		#end			
	end



	def status
		uncommitted = []
		workspace_files = Dir.glob('./**/*').select{ |e| File.file? e and (not e.include? '.octopus') }
			
		committed = ['test1.rb', 'test2.rb']
		workspace_files.each do |path|
			#content = File.read(path)
			#time = File.mtime(path).to_s
			#file_id = Digest::SHA2.hexdigest(content + time)
			#uncommitted.push(path) if Revlog.get_file(file_id) == 'Revlog: File not found'
			uncommitted.push(path) if hash.include?(path) #testing
		end		

		return uncommitted
	end

end
