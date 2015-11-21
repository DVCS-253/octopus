require "test/unit"

#Modules 
require_relative 'PushPull'
require_relative 'RevLog'
require_relative 'Repos'
require_relative 'UserInterface'
require_relative 'Workspace'


## This currently checks to make sure that all modules run, can see eachother
##      and pass the correct paramters and return the correct parameters when using
## =>   inter-module function calls. 
## Once this works, we will focus on makeing sure that the correctness of each function
## =>   is 100% correct. I.e. that push updates the correct files to the correct branch

class IntergrationTest< Test::Unit::TestCase

    def test_UI_to_PushPull(cmd, params)
        if cmd.equal "pull"
            PushPull.pull(params)
        end

        if cmd.equal "push"
            PushPull.push(params)
        end

        if cmd.equal "clone"
            PushPull.clone(params)
        end
    end

    def test_UI_to_Workspace(cmd, params)
        if cmd.equal "checkout"
            Workspace.checkout(params)
        end

        if cmd.equal "commit"
            Workspace.commit(params)
        end

        if cmd.equal "status"
            Workspace.status()
        end
    end

    def test_UI_to_Repos(cmd, params)
        if cmd.equal "branch"
            Repos.branch(params)
        end
    end

    def test_PushPull_from_Repos(cmd, params)
        #Can send a snapshot to add to a branch
    end

    def test_PushPull_to_Repos(cmd, params)
        #Can send a merge request and snapshot to merge two snapshots
    end

    def test_Repos_from_Revlog(cmd, params)
        #Repos recieves contents of committed files and gets file ID
    end

    def test_PushPull_from_Workspace(cmd, params)
        #PushPull recieves latest snapshot ID from Workspace
    end
end


#Current Test
def test_UI_to_Workspace(cmd, params)
     w = Workspace.new()

    if cmd.eql? "checkout"
        w.check_out(params)
    end

    if cmd.equal? "commit"
        Workspace.commit(params)
    end

    if cmd.equal? "status"
        Workspace.status()
    end
end

test_hash = Hash.new
test_hash[:branch] = "Jamie_Dev"
test_UI_to_Workspace("checkout",test_hash)

test_hash = Hash.new
test_hash[:file1] = "filename.dat"
test_UI_to_Workspace("commit",nil)
test_UI_to_Workspace("commit",test_hash)


