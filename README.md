# octopus

### Push and Pull
Octopus supports pushing and pulling branches to and from remotes.

##### Public Methods
###### `PushPull.connect(remote, path)`
Opens an SSH connection to the remote and changes into the given path. The path is expected to be the location of the repository on the remote.

This method attempts to connect as the current user without a password, and then asks for credentials if that fails. To configure passwordless connections with Octopus, you'll need to do the following:

- Run `ssh-keygen -t rsa` to generate a new key
  - Answer `~/.ssh/id_rsa-octopus-remote` for the location
  - Don't enter a password
- Edit `~/.ssh/config` and add the following entry:
  ```
Host {{{REMOTE_HOSTNAME}}}
    IdentitiesOnly yes
    IdentityFile ~/.ssh/id_rsa-octopus-remote
  ```
- Copy the contents of `~/.ssh/id_rsa-octopus-remote.pub` to `~/.ssh/authorized_keys` on the remote

This is recommended for testing, because credentials are not cached and will be asked for during each test otherwise. The remote for the test cases is `127.0.0.1`.
