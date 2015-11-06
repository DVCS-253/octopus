require 'fileutils'

class Workspace

  ##Public Function: clean
  def clean_files(path, staged_folder)
    Dir.foreach(path) do |e|
     next if [".",".."].include? e #filenenames start with . and .. will not be deleted
     next if e == staged_folder
      fullname = path + File::Separator + e
      if FileTest::directory?(fullname)
       FileUtils.rm_rf(fullname)
      else
       File.delete(fullname)
      end
    end
  end
                                          

  def clean
    workspace = '/u/thu/CD class/Implement_test_case/test' #workspace directory
    staged_folder = 'staged_folder' #staged files' location
    clean_files(workspace, staged_folder)
    return 1
  end


  ##public Function: commit
  def directory_history(dir, dest, log)
    Dir.foreach(dir) do |e|
    next if [".",".."].include? e
    fullname = dir + File::Separator + e
      if FileTest::directory?(fullname)
        write_history('commit directory: ' + fullname, log)
        directory_history(fullname, dest, log)			
      else
        write_history('commit file: ' + fullname, log)
      end
    end
  end


  def write_history(text, log)
    File.write(log, text + "\n")
  end


  def commit(path = nil)
    dir = '/u/thu/CD class/Implement_test_case/test/'
    log = dir + '.commit_history'
    dest = dir + 'staged_folder'
    staged_folder = 'staged_folder'
    write_history('COMMIT', log)
    if path == nil #copy all the files/directories in workspace to the staged_folder
      Dir.foreach(dir) do |e|
        next if [".",".."].include? e #commit history file is not necessary to committed
        next if e == staged_folder
        fullname = dir + File::Separator + e
        if FileTest::directory?(fullname)
          write_history('commit directory: ' + fullname, log)
          FileUtils.cp_r(fullname, dest)
          directory_history(fullname, dest, log)
        else
          write_history('commit file: ' + fullname, log)
          FileUtils.cp(fullname, dest)
        end
      end	
      return 1
    end
    if File.directory?(dir + path)#copy all the files/directories in given directory to the folder
      write_history('commit directory: ' + path, log)
      FileUtils.cp_r(dir + path, dest)
      directory_history(dir + path, dest, log)
      return 1
    end
    if File.file?(dir + path)#copy the file to the folder
      write_history('commit file: ' + path, log)
      FileUtils.cp(dir + path, dest)
      return 1
    end
    return 0
  end


end
