
**Dependency:** Revlog, Repos

**List of involved Repos functions:**
- Repos.init : used in workspace init function
- Repos.restore_snapshot : used to get a snapshot object. Called in check_out_snapshot, check_out_file and commit
- Repos.get_head : get the head of a branch. Called in check_out_file, checkout 
- Repos.update_head : update the head of the branch. Called in commit
- Repos.make_snapshot : make a new snapshot given committed files. Called in commit.

**List of involved Revlog funtions:**
Revlog.get_file : given a file_id to get its content. Called in status, check_out_snapshot, check_out_file

**List of functions:**
- init :public function, initialize workspace
- rebuild_dir(path) : rebuild a path in workspace
- check_out_snapshot(snapshot_id) : checke out a snapshot given its ID
- check_out_file(path) : check out a file given its expected location in workspace
- checkout(arg) : public function, check out a branch, it could check out the current newest snapshot or given a branch name
- build_hash(file_list): build a hash for a list of files. key = file_path, key = file_content
- commit(arg = nil, commit_msg = nil) : public function, commit whole workspace, a directory or a file, a commit message is required
- status : public function, return current uncommitted files 
- clean : remove all the files in workspace expect for files under ./.octpus

**Test cases and assumptions**
To test my module without other modules, I fixed the output of other modules in workspace_testversion.rb, and test the functions in workspace_testversion.

All the commented codes in workspace_testversion are outputs from other modules. All the faked output are commented as "#testing". 



