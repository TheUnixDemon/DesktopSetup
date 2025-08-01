#!/bin/bash

# === vars ===
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WAIT=3 # basic time to wait in between

# === func ===
# sudo temp for unattended install
keep_alive_sudo() {
    if sudo -v; then
        {
            while true; do
                sleep 60
                sudo -n true
            done
        } 2>/dev/null &
        keep_alive=$!
        echo "keep-alive (sudo) started"
        return 0
    else
        echo "authentication failed"
        return 1
    fi
}
# simple user interaction
usr_interact() {
    [[ -n "$1" ]] && echo "$1"
    while true; do
        read -p "Confirm? (y/N) " answer
        case $answer in
            y|Y)
                return 0
            ;;
            n|N)
                return 1
            ;;
            *)
            continue
            ;;
        esac
    done

}
# installing required software
install_requirements() {
    sudo pacman -Syu --noconfirm --needed openssh borg python-llfuse rsync && return 0
    return 1
}
# rsync recovery
make_recovery() {
    # recovery locations
    declare -A sync_dirs=(
        ["$BORG_HOME/"]="$HOME"
    )
    # make recovery with borg archive to local OS
    for source in "${!sync_dirs[@]}"; do
        dest="${sync_dirs[$source]}" # key(source) -> value(dest)
        if [[ -e "$source" && -e "$dest" ]]; then
            rsync -avP --exclude-from="$ROOT_DIR/exclude.txt" "$source" "$dest" && echo "successfully synchronized from *$source* to *$dest*"
        else
            echo "*$source* or *$dest* doesn't exists; skipping *$source* -> *$dest*"
        fi
    done
}

# === pre act ===
# keep alive sudo permission
keep_alive_sudo || exit 1
# pre install required software
prefix="installing software requirements ..."
if install_requirements; then
    echo "$prefix successful"
else
    echo "$prefix unsuccessful"
    exit 1
fi

# === main ===
# loading scripts
source "$ROOT_DIR/packages/core.sh"; sleep $WAIT # install packages & enable services 
source "$ROOT_DIR/borg/core.sh"; sleep $WAIT # borg backup connection & mounting
# installing software setup
while true; do
    usr_interact "package installation via Pacman, Yay & Flatpak" && break
done
echo "starting package installation installation ..."; sleep $WAIT
install_pkgs # installing packages
setup_services # enabling & setting up services
load_modules # load kernel modules
# copying backup to local OS using rsync
while true; do
    usr_interact "data recovery using Borg & Rsync" && break
done
echo "starting data recovery process ..."; sleep $WAIT
make_recovery

# === post act ===
# unmount used archive
prefix="unmounting 'latest::$latest' at '$MOUNT_DIR' ..."
if do_unmount; then
    echo "$prefix successful"
else
    echo "$prefix unsuccessful"
fi
# undo keep alive sudo permission
if [[ -n "$keep_alive" ]] && kill -0 "$keep_alive" 2>/dev/null; then
    kill "$keep_alive" && echo "removed keep-alive (sudo) process"
fi