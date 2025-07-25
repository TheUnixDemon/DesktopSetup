# Arch Installation Script

A post-installation script for **Arch Linux/EndeavourOS**. It Installs automaticly packages that are declared within the `packages/**/*.txt` files and transfers data from a borgbackup server to the current operating system.

# Getting Started

For a complete installation & syncing, make use of `./src/main.sh`. Before that It's recommend to change the mounting location declared in `./src/borgserver.sh`. Also before that you have to configure the connection to your borgbackup server. 

```bash
#!/bin/bash
./src/main.sh
```

## <u> Borgbackup </u>

Change location of the declared mounting directory `mount_dir` if needed. The location paths that are to transfer from the source (borgbackup archive) to the destination (current OS) are declared as map/dict. Also the script checks if both directories exits and tranfers the data via `rsync` to the destination afterwards.

### Borgbackup Server

To get the connection to a running borgbackup server running. You have to define a SSH URL, get your SSH private key ready and declare the repository password. Look for that into the `./src/borgserver.sh`.

```bash
#!/bin/bash

...

# borg server
ssh_key="$ROOT_DIR/server/backupserver" # change me
ssh_port=22 # change me
repo="ssh://borg@server:$ssh_port/mnt/repo" # change me
repo_password="$ROOT_DIR/server/pass.txt" # optional
```

So `ssh_key`, `ssh_port` (if not port 22) and the `repo` adress has to be definied. The `repo_password` must not be given, but if so you don't have to put in the password for your borgbackup repository by hand.

## <u> Seperately Setting Up </u>

It's also possible to use the scripts `./src/inst.sh` and `./src/borgserver.sh` seperately. The `./src/main.sh` does load first the installation script and after that the borgbackup server script. But only in `./src/main.sh` is the function implemented to keep-alive the sudo permission, so for a unattended installation it's recommended to use that script.

### Installation Script

To install declared packages with Pacman, Yay and Flatpak. Afterwards it's loading manually the needed kernel modules (also declared in a file) and setting up services like database servers and more. 

```bash
#!/bin/bash
./src/inst.sh # installing (via pacman, yay & flatpak) and enabling services
```

### Borgbackup Script

To transfer data from borgbackup archive to current OS.

```bash
#!/bin/bash
./src/borgserver.sh # recovery data using rsync
```