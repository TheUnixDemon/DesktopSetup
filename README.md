# Arch Installation Script

Post-installation script for **Arch Linux/EndeavourOS**. Installs automaticly packages that are declared within the `packages/**` files and transfers data from a borgbackup server to the current operating system. 

# Getting Started

For a complete installation & syncing, make use of `./src/main.sh`. Before that It's recommend to change the mounting location declared in `./src/borgserver.sh`.

```bash
#!/bin/bash
./src/main.sh
```

## <u> Borgbackup Server </u>

Change location of the declared mounting directory `mount_dir` if needed. The location paths that are to transfer from the source (borgbackup archive) to the destination (current OS) are declared as map or dict. Also the script checks if both directories exits and tranfers the data via `rsync` to the destination.

## <u> Seperately Setting Up </u>

It's also possible to use the scripts `./src/inst.sh` and `./src/borgserver.sh` seperately. The `./src/main.sh` does load first the installation script and after that the borgbackup server script. But only in `./src/main.sh` is the function to keep-alive the sudo permission implemented so for a unattended installation it's recommended to use that script.

To install declared packages with Pacman, Yay and Flatpak. Afterwards it's loading manually the needed kernel modules (also declared in a file) and setting up services like database servers and more. 

```bash
#!/bin/bash
./src/inst.sh # installing (via pacman, yay & flatpak) and enabling services
```

To transfer data from borgbackup archive to current OS.

```bash
#!/bin/bash
./src/borgserver.sh # recovery data using rsync
```