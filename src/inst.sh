#!/bin/bash

# env
if [[ -z "$ROOT_DIR" ]]; then
    export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# packages
pkgs_dir="$ROOT_DIR/packages"

# pacman pkgs
pacman_pkgs_dir="$pkgs_dir/pacman"
nvidia_pkgs="$pacman_pkgs_dir/nvidia.txt"
amd_pkgs="$pacman_pkgs_dir/amd.txt"
pacman_pkgs="$pacman_pkgs_dir/pkgs.txt"

# yay
yay_pkgs_dir="$pkgs_dir/yay"
yay_pkgs="$yay_pkgs_dir/pkgs.txt"

# flatpak
flatpak_pkgs_dir="$pkgs_dir/flatpak"
flatpak_pkgs="$flatpak_pkgs_dir/pkgs.txt"

# modules
modules_list="$pkgs_dir/modules.txt"

# checking if package file exits
check_pkgs() {
    for pkgs_file in "$@"; do
        echo "loading pkg file *$pkgs_file* ..."
        if [[ ! -f "$pkgs_file" ]]; then
            echo "*$pkgs_file* not found; abort installation"
            return 1
        fi
    done
    return 0
}

# installs packages with pacman (offical pkgs)
inst_pacman_pkgs() {
    echo "installaing packages via Pacman (offical)"
    if check_pkgs "$@"; then # checking if pkgs file is existing
        # installing pkgs
        pkgs=$(grep -hvE "^\s*#|^\s*$" "$@")
        if [[ -n "$pkgs" ]]; then
            echo -e "following packages will be installed ...\n$pkgs"
            sudo pacman -Syu --noconfirm --needed $pkgs && echo "installation successfully" && return 0
            echo "installation failed"
        else
            echo "pkg files are empty; abort installation"
        fi
    fi
    return 1
}

# installs packages with yay (aur pkgs)
inst_yay_pkgs() {
    echo "installaing packages via Yay (aur)"
    if check_pkgs "$@"; then # checking if pkgs file is existing
        # installing pkgs
        pkgs=$(grep -hvE "^\s*#|^\s*$" "$@")
        if [[ -n "$pkgs" ]]; then
            echo -e "following packages will be installed ...\n$pkgs"
            sudo pacman -Syu --noconfirm --needed $pkgs && echo "installation successfully" && return 0
            echo "installation failed"
        else
            echo "pkg files are empty; abort installation"
        fi
    fi
    return 1
}

# installs packages with flatpak
inst_flatpak_pkgs() {
    echo "installaing packages via Flatpak"
    if check_pkgs "$@"; then # checking if pkgs file is existing
        # installing pkgs
        pkgs=$(grep -hvE "^\s*#|^\s*$" "$@")
        if [[ -n "$pkgs" ]]; then
            echo -e "following packages will be installed ...\n$pkgs"
            for pkg in "$pkgs"; do
                flatpak install -y flathub $pkg && echo "installation of *$pkg* successfully" && return 0
                echo "installation failed"
            done
        else
            echo "pkg files are empty; abort installation"
        fi
    fi
    return 1
}

# installation packages
inst_packages() {
    echo "installing requirements with Pacman, Yay & Flatpak"
    inst_pacman_pkgs $nvidia_pkgs $pacman_pkgs || return 1
    inst_yay_pkgs $yay_pkgs || return 1
    inst_flatpak_pkgs $flatpak_pkgs || return 1
    return 0
}

# loading kernel modules
load_modules() {
    echo "loading modules file *$modules_list* ..."
    if [[ -f "$modules_list" ]]; then
    kernel_modules=$(grep -hvE "^\s*#|^\s*$" "$modules_list")
        if [[ -n "$kernel_modules" ]]; then
            echo "$kernel_modules"
            sudo modprobe "$kernel_modules" && return 0
        else
            echo "*$modules_list* is empty"
        fi
    else
        echo "*$modules_list* not found"
    fi
    return 1
}

# only postgresql specificly
psql_setup() {
    echo "PostgreSQL setup was ..."
    if sudo su postgres -c "initdb -D /var/lib/postgres/data" && sudo systemctl enable --now postgresql; then
        echo "successful"
        return 0
    else
        echo "unsuccessful"
    fi
    return 1
}

# services setup
service_setup() {
    echo "following services ..."
    systemctl --user enable --now opentabletdriver.service && echo "*OpenTabletDriver*" || echo "*OpenTabletDriver* (failed)"
    echo "enabled"
}

# installing packages
inst_packages && load_modules || exit 1
# services (no automatic aborting)
psql_setup # setup postgresql
service_setup # other services