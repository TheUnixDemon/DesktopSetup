# Arch Installation Script

A half-unattended post-installation script for **Arch Linux**. It installs  packages that are declared within the `./src/packages/**/*.txt` files and transfers data from a Borg server to the current operating system using Rsync.

# Getting Started

For a complete installation & syncing excute the main script `./src/main.sh`. **But** before that it is required to configure the connection to the Borg server by creating a script named `./src/borg/conf/conf.sh`. Here an example how this configuration script should look like.

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

After that execute the `./src/main.sh` and check it's output. If the checks are looking good it's time to continue the process using direct confirmation by the user.

## <u> Configuration </u> 

First of all the configuration variables `BORG_PASSPHRASE` and `BORG_RSH` are optional. If you are using SSH to communicate with your external Borg server you have to use `BORG_RSH`. But if the targeted Borg server is locally and not through SSH `BORG_RSH` do not set this variable at all. `SSH_KEYFILE` can be ignored if `BORG_RSH` is of no use for you.

Furthermore If `BORG_PASSPHRASE` is set you don't have to input the password by hand but the connection will be directly without user interaction. If not you will be requested to input that password everytime you want to connect again using this script.

## <u> How It Works </u>

If the `./src/main.sh` is started it installs it's required packages via Pacman. After that It loads both core scripts `./src/borg/core.sh` and `./src/packages/core.sh`. Before the process of installation and data recovery starts. The core scripts are checking if, first of all, the package files (`./src/packages/pacman/*.txt`, `...`) are to be found and last but not least if the Borg server is reachable, the connection is successful, archives are found and can be mounted to the desired location. After that the process is split in two. Firstly the **installation** process of packages declared in those package files and secoundly the **data recovery** via Borg and Rsync. Inbetween the user has to confirm that the script should continue it's normal course. This interaction is recommended to keep for checking the results of package installation by hand before continuing.

### Packages

If you want to use this as base for a half-unattended install like I'm doing you should change up at least every package file (look below for more). So basicly go through `./src/packages/core.sh`. The package file locations are defined in the `./src/packages/install.sh`.

For base driver I wrote down two package files `./src/packages/amd.txt` and `./src/packages/nvidia.txt`. Because I'm using mainly my Nvidia graphicscard you should change one line if you have an amd graphicscard. Also some driver are written down within `./src/packages/pacman/pkgs.txt`. What for package files are loaded with which packagemanager is written down in the script `./src/packages/core.sh`.

```bash
#!/bin/bash
...
install_pkgs() {
    inst_pacman_pkgs $nvidia_pkgs $pacman_pkgs # for nvidia
    inst_pacman_pkgs $amd_pkgs $pacman_pkgs # for amd
    inst_yay_pkgs $yay_pkgs
    inst_flatpak_pkgs $flatpak_pkgs
}
```

Paste packages to the `**/pkgs.txt` of your choice. The comments in those files have to be seperated from the package declaration using a new line.

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

Flatpak doesn't support token based packages chained together as valid parameter so one after another will be installed. Pacman and Yay can both chain them together so these have to be executed only ones.

```bash
#!/bin/bash
# Pacman
sudo pacman -Syu --noconfirm --needed package-1 package-2 package-3 package-4
# Yay
yay -Syu --noconfirm --needed package-1 package-2 package-3 package-4
# Flatpak
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

The first line will be ignored because of the `#` symbol so you better not mix them together with package declaration lines.

### Rsync

The locations that will be tranfered are defined in the `./src/main.sh`.

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

`sync_dirs` is a map. The *key* (`$BORG_HOME/`) is the location of the Borg archive and the *value* (`$HOME`) should be a location on your localhost.

Here as example the complete content of the mounted archive and it's home directory will be *synchronized* to the home directory of the current user.

```bash
#!/bin/bash
rsync -avP --exclude-from="$ROOT_DIR/exclude.txt" "$BORG_HOME/" "$HOME" # key -> value
```

#### *Exclude Patterns*

If you want to exclude folders or files you can put your patterns into the `./src/exclude.txt`.

```bash
**/Downloads/**
**/.wine/**
**/.cache/**
**/Trash/**
**/*.log
```

# My Setup

Here my essential software parts that I would install on every desktop setup that I use. I don't include AMD and their drivers because I usually don't use them (but my notebook does).

## <u> Operating System </u>
* Arch Linux 64 Bit - **x86**
* Cinnamon Wayland **&** KDE Plasma 6 Wayland
* Nvidia driver
    * `nvidia` (not `nvidia-dkms`)
    * `nvidia-utils` & `lib32-nvidia-utils`

Currently I'm using KDE Plasma 6 Wayland because it's more stable than years before. Back in the day, KDE Plasma 6 had some terrible issues with its stability and support for Nvidia, so basically it sometimes crashed randomly or had screen tearing. Then I switched for more than two years (2023–2025) to Cinnamon because of its stability (based on older GNOME), and it fixed most of my issues. As said, nowadays KDE Plasma 6 Wayland is stable enough to use it even with Nvidia cards, but if you have issues, I can recommend checking out Cinnamon.

`nvidia-dkms` will be locally compiled everytime a new version comes up so it takes much longer than `nvidia` because `nvidia` is pre-compiled. So why then so many recommend `nvidia-dkms`? It's basicly with every kernel compatible so it should work fine under every kernel. But If you're using the stable kernel (default) then I strongly recommend to switch to `nvidia`.

## <u> Compatibily Layer </u>
* `wine` (stable)
* `wine-gecko` 
* `wine-mono`
* `winetricks`
* `umu-launcher` (proton)

I am using Linux full time and can handle my *Wine* prefixes by myself (mostly) so I'm usually not using *Lutris* as compatibily layer handler. If you have problems with the terminal try *Lutris*. Also I like to use *umu-launcher* for using Proton from Steam without using it through (outside of) Steam. *umu-launcher* allows to use *winetricks* for the installation of *dlls* and has a better compatibility out-of-the-box than *Wine* without installing directly additional *dlls*.

## <u> Utility Tools </u>
* `gamemode`
* `gamescope` & `lib32-gamemode`

More performance through *gamemoderun* and *gamescope* makes window issues (mostly) obsolete.