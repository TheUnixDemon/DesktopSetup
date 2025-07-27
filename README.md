# Arch Installation Script

A half-unattended post-installation script for **Arch Linux**. It installs  packages that are declared within the `./src/packages/**/*.txt` files and transfers data from a Borg server to the current operating system using Rsync.

# Getting Started

For a complete installation & syncing excute the main script `./src/main.sh`. But before that it is required to configure the connection to the Borg server by creating a script named `./src/borg/conf/conf.sh`. Here an example how this configuration script should look like.

```bash
#!/bin/bash
# === conn config & auth ===
# reference file
SSH_KEYFILE="PATH/YOUR-SSHKEY" # location of ssh private key
# borg repo
BORG_REPO="ssh://USERNAME@HOSTNAME:PORT/PATH" # repo address *REQUIRED
BORG_PASSPHRASE="PASSWORD" # repo password *OPTIONAL
# ssh conn
BORG_RSH="ssh -i '$SSH_KEYFILE'" # ssh auth *OPTIONAL
# === local config ===
MOUNT_DIR=/tmp/borg # borg archive mount location *REQUIRED
BORG_HOME="$MOUNT_DIR/home/USERNAME" # borg archive home location *REQUIRED
```

## <u> Configuration </u> 

First of all the configuration variables `BORG_PASSPHRASE` and `BORG_RSH` are optional. If you are using SSH to communicate with your external Borg server you have to use `BORG_RSH`. But if the targeted Borg server is locally and not through SSH `BORG_RSH` do not set this variable at all. `SSH_KEYFILE` can be ignored if `BORG_RSH` is of no use for you.

Furthermore If `BORG_PASSPHRASE` is set you don't have to input the password by hand but the connection will be directly without user interaction. If not you will be requested to input that password everytime you want to connect again using this script.

## <u> How It Works </u>

If the `./src/main.sh` is started it installs it's required packages via Pacman. After that It loads both core scripts `./src/borg/core.sh` and `./src/packages/core.sh`. Before the process of installation and data recovery starts. The core scripts are checking if, first of all, the package files (`./src/packages/pacman/*.txt`, `...`) are to be found and last but not least if the Borg server is reachable, the connection is successful, archives are found and can be mounted to the desired location. After that the complete process is split in two. Firstly the installation process of packages declared in those package files and secoundly the data recovery via Borg and Rsync. Inbetween the user has to confirm that the script should continue it's normal course. This interaction is recommended to keep for checking the results of package installation by hand and after that the data recovery starts and that's it.

### Packages

If you want to use this as base for a half-unattended install like I'm doing you should change up at least every package file (look below for more). So basicly go through `./src/packages/core.sh`. The package file locations are defined in the `./src/packages/install.sh`.

For base driver I wrote down two package files `./src/packages/amd.txt` and `./src/packages/nvidia.txt`. Because I'm using mainly my Nvidia graphicscard you should change one line if you have an amd graphicscard. Also some driver are written down within `./src/packages/pacman/pkgs.txt`. What for package files are loaded with which packagemanager is written down in the script `./src/packages/core.sh`.

```bash
#!/bin/bash
...
install_pkgs() {
    inst_pacman_pkgs $nvidia_pkgs $pacman_pkgs # for nvidia
    inst_pacman_pkgs $amd_pkgs $pacman_pkgs # for amd
    ...
...
}
```

Paste packages to the `**/pkgs.txt` of your choice. Two things are to pay attention. Firstly packages will be seperately placed into a new line and secoundly comments can be made but you can't mix up a line that is used up for a package declaration with a comment line.

#### *Positive Example*

Here an example how a `**/pkgs.txt` should look like.

```bash
# comment 1
package-1
# comment 2
package-2
# comment 3
package-3
package-4
```

And here you can see how the packagemanagers will interpret this example `**/pkgs.txt` file. Flatpak doesn't support token based packages chained together as valid parameter so one after another will be installed. Pacman and Yay can both chain them together so these both have to execute only ones per installation.

```bash
#!/bin/bash
# pacman
sudo pacman -Syu --noconfirm --needed package-1 package-2 package-3 package-4
# yay
yay -Syu --noconfirm --needed package-1 package-2 package-3 package-4
# flatpak
flatpak install -y flathub package-1
flatpak install -y flathub package-2
flatpak install -y flathub package-3
flatpak install -y flathub package-4
```

#### *Negative Example*

Now a bad example how the `**/pkgs.txt` would not work.

```bash
package-1 # comment 1
package-2
```

The first line will be ignored because a `#` symbol so you better not mix them together with package declaration lines.

### Rsync

The locations that are to transfer/sync are defined in the `./src/main.sh`.

```bash
#!/bin/bash
...
make_recovery() {
    # recovery locations
    declare -A sync_dirs=(
        ["$BORG_HOME/"]="$HOME"
    )
    ...
}
...
```

`sync_dirs` is a map (in Python known as dict). The *key* (`$BORG_HOME/`) is the location of the Borg archive and the *value* (`$HOME`) should be a location on your localhost. The data transfer goes from the *key* synchronized to the *value*.

Here as example the complete content of the mounted archive and it's home directory will be "copied" to the home directory of the current user. The command that will be executed internally looks like this.

```bash
#!/bin/bash
rsync -avP --exclude-from="$ROOT_DIR/exclude.txt" "$BORG_HOME/" "$HOME"
```

#### *Exclude Patterns*

If you want to exclude folders or files you can put your patterns into the `./src/exclude.txt`. Here an example how it could look like.

```bash
**/Downloads/**
**/.wine/**
**/.cache/**
**/Trash/**
**/*.log
```

# My Setup

Here some informations about my software setup so those who doesn't know if package **xy** should remain or not here some favourites of mine.

## <u> Software </u>

Here my essential software parts that I would install on every desktop setup.

### Base Sys
* Arch Linux 64 Bit - **x86**
* Cinnamon Wayland **or** KDE Plasma 6 Wayland
* fitting graphicsdriver & vulkan support
    * nvidia (not nvidia-dkms)
    * nvidia-utils
    * lib32-nvidia-utils

So why not `nvidia-dkms`? `nvidia-dkms` will be locally compiled everytime a new version comes up so it takes much longer than `nvidia` because `nvidia` is pre-compiled. So why then so many recommend `nvidia-dkms`? It's basicly with every kernel compatible so it should work fine under every kernel. But If you're using the stable kernel (default) then I strongly recommend to switch to `nvidia`.

### Compatibily Layer
* wine (stable)
* wine-gecko
* wine-mono
* winetricks
* umu-launcher (proton)

Why `wine` and `umu-launcher`? I am using Linux fulltime and can handle custom but more lightweight compatibily layers like wine instead of using `Lutris`. If you have problems with the terminal try `Lutris`. Or use Windows alongside instead.

### Utility Tools
* gamemode
* lib32-gamemode
* gamescope

More performance through `gamemoderun` and `gamescope` makes window issues with mostly Windows applications obsolete.

# Last Words

This script does not make backups through Borg by itself but depends on software like **Vorta**. It's possible to code additionally a service that does that alongside the Borg backup creation but I think Vorta and other applications like that are working very good with desktop envirounments so It would be overkill and mostly useless for those that prefer Vorta.