#!/bin/bash

# === vars ===
# borg repo
if [[ -v BORG_REPO && -v BORG_PASSPHRASE ]]; then
    export BORG_REPO
    export BORG_PASSPHRASE
else
    echo "both vars *BORG_REPO* & *BORG_PASSPHRASE* have to be set"
    exit 1
fi
# ssh auth
if [[ -v BORG_RSH ]]; then
    if [[ -f "$SSH_KEYFILE" ]]; then
        export BORG_RSH
    else
        echo "'$SSH_KEYFILE' not found"
        exit 1
    fi  
fi
# mounting location; creates folder if not existing
if [[ -v MOUNT_DIR && -n "$MOUNT_DIR" ]]; then
    prefix="mounting location '$MOUNT_DIR' ..."
    if [[ -d "$MOUNT_DIR" ]]; then
        echo "$prefix exists"
    else
        if mkdir -p "$MOUNT_DIR"; then
            echo "$prefix created"
        else
            echo "$prefix can't be created"
            exit 1
        fi
    fi
else
    echo "var *MOUNT_DIR* have to be set"
    exit 1
fi

# === func ===
# checks if connection works
validate_borg_conn() {
    borg info 1> /dev/null && return 0
    return 1
}
# checks if archives are there to recover from
validate_borg_archive() {
    borg list | grep -q . && return 0
    return 1
}
# unmount previous archive from mount location
do_unmount() {
    if mountpoint -q "$MOUNT_DIR"; then
        borg umount "$MOUNT_DIR" && return 0
        return 1
    fi
    return 0
}
# latest archive mount to mounting location
do_mount() {
    # unmounting previous one before mounting new archive
    do_unmount
    borg mount "::$latest" "$MOUNT_DIR" && mountpoint -q "$MOUNT_DIR" && return 0
    return 1
}

# === main ===
prefix="connection '$BORG_REPO' ..."
# checks if connection is working
if validate_borg_conn; then
    echo "$prefix successful"
else
    echo "$prefix unsuccessful"
    exit 1
fi
# checks if at least one archive is there
if ! validate_borg_archive; then
    echo "no archives can be found"
    exit 1
fi
# gets latest archive
prefix="archive   "
latest=$(borg list --short | tail -n 1)
if [[ -n "$latest" ]]; then
    echo "$prefix 'latest::$latest'"
else
    echo "$prefix not found"
    exit 1
fi
# mounting archive
prefix="mounting   'latest::$latest' at '$MOUNT_DIR' ..."
if do_mount; then
    echo "$prefix successful"
else
    echo "$prefix unsuccessful"
    exit 1
fi
# checking home dir within archive
prefix="validating directory '$BORG_HOME' ..."
if [[ -d "$BORG_HOME" ]]; then
    echo "$prefix successful"
else
    echo "$prefix unsuccessful"
    exit 1
fi