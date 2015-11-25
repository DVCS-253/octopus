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
  oct commit -m [commit message] a.txt b.txt
  ```
  
**Status**
At any point in time you can check the status of your repository. 
A list of uncommitted files (files that are either new or changed) will be displayed:
  ```
  oct status
  ```
  
**Branch**
  

