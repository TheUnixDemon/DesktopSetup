#!/bin/bash

backup_mount_dir="/mnt/vorta"
backup_home_dir="$backup_mount_dir/home/theunixdaemon" # backup home dir

# locations to deploy from backup to new system installation
declare -A deploy_dirs=(
    ["$backup_home_dir/"]="$HOME"
)

# copie files from backup location to local system
deploy_backup() {
    if mountpoint -q "$backup_mount_dir"; then
        if [[ -d "$backup_home_dir" ]]; then
            for source in "${!deploy_dirs[@]}"; do
                dest="${deploy_dirs[$source]}"
                if [[ -d "$source" && -d "$dest" ]]; then
                    rsync -avP --exclude-from="$ROOT_DIR/exclude.txt" "$source" "$dest" && echo "successfully copied from *$source* to *$dest*"
                else
                    echo "*$source* or *$dest* doesn't exists"
                    return 1
                fi
            done
            return 0
        else
            echo "*$backup_home_dir* not found"
    else
        echo "nothing mounted at *$backup_mount_dir*"
    fi
    return 1
}