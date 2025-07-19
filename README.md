# Arch Installation Script

Installation script for my Arch Linux setup. Installs automaticly dependencies of my setup on a new installation. Also copies backed up data to new operating system.

# Getting Started

For a complete installation & syncing, you can make use of `./src.main.sh`. Before that I recommend to change the locations declard in `./src/.rsync.sh` (look below).

```bash
#!/bin/bash
./src/main.sh
```

## <u> Rsync Backup Location </u>

Change location of the declared variables `backup_mount_dir` and `backup_home_dir` to the wished ones in `./src/rsync.sh`. `rsync.sh` checks if the path exists. The backed up locations are also declared in the same script file as map/dict.


## <u> Seperatly Setting Up </u>

It's also possible to use seperatly *either* the package installation script *or* the recovery of data using `rsync`. Here only the installation of packages declared in the package files located at `./src/packages/**.txt`.

```bash
#!/bin/bash
./src/inst.sh # install packages with pacman, yay & flatpak
```

Or only copying backup files to the newly installed operating system.

```bash
#!/bin/bash
./src/rsync.sh # recovery data using rsync
```