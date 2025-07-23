#!/bin/bash

# env
if [[ -z "$ROOT_DIR" ]]; then
    export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# borg server
sshkey="$ROOT_DIR/server/backupserver"
sshport=22
repo="ssh://borgbackup@server:$sshport/location/desktop"
pass_file="$ROOT_DIR/server/pass.txt"

# locations
mount_dir="/tmp/borg"
borg_home_dir="$mount_dir/home/theunixdaemon"

# locations to deploy
declare -A deploy_dirs=(
    ["$borg_home_dir/"]="$HOME"
)

# read borg archive password
read_pass() {
    if [[ -f "$pass_file" ]]; then
        export BORG_PASSCOMMAND="cat $pass_file"
    fi
}

# umount archive
do_umount() {
    if [[ -d "$mount_dir" ]]; then
        borg umount "$mount_dir" && return 0
    fi
    return 1 # not mounted
}

# mounting given archive or latest
do_mount() {
    # check if previous archive not umounted
    if mountpoint -q "$mount_dir"; then
        if do_umount; then
            echo "previous archive unmounted"
        else
            echo "previous archive can't be unmounted" && exit 1
        fi
    fi

    archive="$1" # choosen archive to mount & deploy
    if [[ -z "$archive" ]]; then # selecting latest archive if not definied
        archive=$(borg list --short "$repo" | tail -n 1) && echo "latest: *$archive*"
    fi
    # checking mount dir
    if [[ ! -d "$mount_dir" ]]; then
        mkdir -p "$mount_dir" && echo "mount directory *$mount_dir* created"
    fi
    # mounting
    borg mount "$repo::$archive" "$mount_dir" && mountpoint -q "$mount_dir" && return 0
    return 1
}

# deploy archive backup to system using *deploy_dirs*
deploy() {
    if do_mount; then
        echo "successfully mounted *$archive* at *$mount_dir*"
    fi
    for source in "${!deploy_dirs[@]}"; do
        dest="${deploy_dirs[$source]}" # key(source) -> value(dest)
        if [[ -e "$source" && -e "$dest" ]]; then
            rsync -avP --exclude-from="$ROOT_DIR/exclude.txt" "$source" "$dest" && echo "successfully copied from *$source* to *$dest*"
        else
            echo "*$source* or *$dest* doesn't exists; skipping *$source*; *$dest*"
        fi
    done
    if do_umount; then
        echo "unmounted archive at *$mount_dir*"; 
    fi
}

# for server conn
export BORG_RSH="ssh -i '$sshkey'" # sets ssh key
read_pass # sets pass for borg repo

# mounting & deploying
deploy