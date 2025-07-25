#!/bin/bash

# env
if [[ -z "$ROOT_DIR" ]]; then
    export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# borg server
ssh_key="$ROOT_DIR/server/backupserver"
ssh_port=22
repo="ssh://borg@server:$ssh_port/mnt/repo"
repo_password="$ROOT_DIR/server/pass.txt"

# locations
mount_dir="/tmp/borg"
borg_home_dir="$mount_dir/home/theunixdaemon"

# locations to deploy
declare -A deploy_dirs=(
    ["$borg_home_dir/"]="$HOME"
)

# read borg archive password
read_pass() {
    if [[ -f "$repo_password" ]]; then
        export BORG_PASSCOMMAND="cat $repo_password" && echo "successfully loaded repository passoword" && return 0
        echo "couldn't read repository password from *$repo_password*"
    fi
    return 1
}

# umount archive
do_umount() {
    borg umount "$mount_dir" && return 0
    return 1
}

# mounting given archive or latest
do_mount() {
    # check if previous archive not umounted
    if mountpoint -q "$mount_dir"; then
        if do_umount; then
            echo "previous archive unmounted"
        else
            echo "previous archive can't be unmounted"
            return 1
        fi
    fi
    # select archive
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
    for source in "${!deploy_dirs[@]}"; do
        dest="${deploy_dirs[$source]}" # key(source) -> value(dest)
        if [[ -e "$source" && -e "$dest" ]]; then
            rsync -avP --exclude-from="$ROOT_DIR/exclude.txt" "$source" "$dest" && echo "successfully synchronized from *$source* to *$dest*"
        else
            echo "*$source* or *$dest* doesn't exists; skipping *$source* -> *$dest*"
        fi
    done
}

# unmounts (if needed), mounts, deploys backed up data and umounts again
make_recovery() {
    # checks if previous is mounted & mounting latest or specific archive
    if do_mount; then
        echo "successfully mounted *$archive* at *$mount_dir*"
    else
        echo "mounting at *$mount_dir* failed"
        return 1
    fi
    # deploy data
    deploy && echo "synchronization process finished"
    # umounting 
    if mountpoint -q "$mount_dir"; then
        do_umount && echo "unmounted *$archive* at *$mount_dir* successfully" || return 1
    fi
    return 0
}

# server connection
if [[ ! -f "$ssh_key" ]]; then
    echo "*$ssh_key* not found (needed); abort"
    exit 1
fi
export BORG_RSH="ssh -i '$ssh_key'" # sets ssh key
read_pass # sets pass for borg repo

# transfer data from borgserver to recover data
echo "starting recovery process ..."
make_recovery && echo "finished recovery process" || echo "failed recovery process"