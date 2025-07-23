#!/bin/bash

# env
if [[ -z "$ROOT_DIR" ]]; then
    export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

backup_mount_dir="/temp/vorta"
backup_home_dir="$backup_mount_dir/home/theunixdaemon" # backup home dir

# locations to deploy from backup to new system installation
declare -A deploy_dirs=(
    ["$backup_home_dir/"]="$HOME"
)

mount_backup() {
    # creating mount directory
    if [[ ! -d "$backup_mount_dir" ]]; then
        mkdir -p "$backup_mount_dir" && echo "created temp dir *$backup_mount_dir*"
    fi 
}

# copie files from backup location to local system
deploy_backup() {
    if mountpoint -q "$backup_mount_dir"; then
        if [[ -d "$backup_home_dir" ]]; then
            for source in "${!deploy_dirs[@]}"; do
                dest="${deploy_dirs[$source]}"
                if [[ -e "$source" && -e "$dest" ]]; then
                    rsync -avP --exclude-from="$ROOT_DIR/exclude.txt" "$source" "$dest" && echo "successfully copied from *$source* to *$dest*"
                else
                    echo "*$source* or *$dest* doesn't exists; skipping *$source*; *$dest*"
                fi
            done
            return 0
        else
            echo "*$backup_home_dir* not found"
        fi
    else
        echo "not mounted at *$backup_mount_dir*"
    fi
    return 1
}

deploy_backup # copying from backup to new installation