## Installation
- Clone this repository onto your computer (use the oct branch)
- Run `bundle install` to install Ruby dependencies.
  - If you don't have bundler, run `gem install bundler`
- Add the path to this repository to your `PATH` variable inside `~./cshrc` file.
  
## Usage
You have two options for setting up octopus repository.
You can either create a repository from scratch:
  ```
  oct init
  oct -help # For a full list of commands
  ```
  
You can also clone an existing octopus repository:
  ```
  oct clone username@host:path/to/octopus/repo
  ```
  
**Commit**

You can commit a file, or a number of files together with a required commit message:
  ```
  oct commit -m "commit message" a.txt b.txt
  ```
*Note: currently commit message can only be one word long. Sorry for the inconvinience.* 

**Status**

At any point in time you can check the status of your repository. 

A list of uncommitted files (files that are either new or changed) will be displayed:
  ```
  oct status
  ```
  
**Branching**

You have an option of making a new branch. By default, the first branch created is called "master".

Creating a new branch immidiately moves you to it:
  ```
  oct branch -a new_branch_name
  ```
  
**Checkout**

You can checkout the latest commit of a given branch name. 

For example, let's imagine you have initiated octopus reposity, made a couple commits and then created decided
to create a new branch. You have made a couple commits on a new branch and then realized that you want to look
back to the last state of your original branch "master". Here is how the following would look like:
  ```
  oct init
  oct commit -m "first_commit" hello_world.java learning_ruby.rb
  oct commit -m "second_commit" hello_world.java learning_ruby.rb first_project.c
  oct status 
  oct branch -a fixing_bug_01
  oct commit -m "fixing_bug" first_project.c supplimentary_file1.c
  oct commit -m "fixing_bug2" first_project.c supplimentary_file2.c
  oct checkout master
  ls # Will output hello_world.java learning_ruby.rb first_project.c
  ```
  
As shown above - please be aware that checking out different branches will remove any uncommited files from
your current working directory.



