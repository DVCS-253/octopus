require "test/unit"

#Modules 
require_relative 'RevLog'
#require_relative 'Repos'
require_relative 'UserInterface'
require_relative 'Workspace'
#require_relative 'PushPull'



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

    end

    def test_Revlog_to_Repos(cmd, params)

    end

    def test_PushPull_from_Workspace(cmd, params)
    
    end
end


#Current Test
def test_UI_to_Workspace(cmd, params)
    if cmd.eql? "checkout"
        Workspace.checkout(params)
      #  puts "Ran"
    else
      #  puts "didnt run"
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

