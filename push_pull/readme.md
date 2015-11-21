## Push/Pull
Octopus supports pushing and pulling branches to and from remotes.

### Dependencies
This module depends on the Net::SSH gem for Ruby. You can install it with the `Gemfile` by running `bundle install`. If you do not have bundler installed, you can get it with `gem install bundler`.

### Public Methods
###### `PushPull.connect(remote, path)`
Opens an SSH connection to the remote and changes into the given path. The path is expected to be the location of the repository on the remote.

This method attempts to connect as the current user without a password, and then asks for credentials if that fails. To configure passwordless connections with Octopus, you'll need to do the following:

- Run `ssh-keygen -t rsa` to generate a new key
  - Answer `~/.ssh/id_rsa-octopus-remote` for the location
  - Don't enter a password
- Edit `~/.ssh/config` and add the following entry, replacing `{{{REMOTE_HOSTNAME}}}` with the remote hostname

  ```
Host {{{REMOTE_HOSTNAME}}}
        IdentitiesOnly yes
        IdentityFile ~/.ssh/id_rsa-octopus-remote
  ```
- Copy the contents of `~/.ssh/id_rsa-octopus-remote.pub` to `~/.ssh/authorized_keys` on the remote

This is recommended for testing, because credentials are not cached and will be asked for during each test otherwise. The remote for the test cases is `127.0.0.1`.

---

###### `PushPull.clone(remote, directory_name = nil)`
Copies a remote repository to a new local directory. If a directory name isn't given, the name of the repository on the remote will be used.

---

###### `PushPull.pull(remote, branch)`
Pulls new changes from the remote repository's branch to the local repository. The remote should be formatted as `machine.address:/path/to/repo`.

---

###### `PushPull.push(remote, branch)`
Pushes new changes from the local repository's branch to a remote repository. The remote should be formatted as `machine.address:/path/to/repo`.
