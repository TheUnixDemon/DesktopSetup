#!/bin/bash

# === vars ===
pkgs_dir="$PKGS_WORKING_DIR/packages"
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

# === preparation funcs ===
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
# checking needed module/package files
check_resource_files() {
    check_pkgs $nvidia_pkgs $amd_pkgs $pacman_pkgs $yay_pkgs $flatpak_pkgs $modules_list || return 1
    return 0
}

# === installation funcs ===
# installs packages with pacman (offical pkgs)
inst_pacman_pkgs() {
    echo "installaing packages via Pacman (offical)"
    # installing pkgs
    pkgs=$(grep -hvE "^\s*#|^\s*$" "$@")
    if [[ -n "$pkgs" ]]; then
        echo -e "following packages will be installed ...\n$pkgs"
        sudo pacman -Syu --noconfirm --needed $pkgs && echo "installation successfully" && return 0
        echo "pacman - installation failed"
    else
        echo "pkg files are empty"
    fi
    exit 1
}
# installs packages with yay (aur pkgs)
inst_yay_pkgs() {
    echo "installaing packages via Yay (aur)"
    # installing pkgs
    pkgs=$(grep -hvE "^\s*#|^\s*$" "$@")
    if [[ -n "$pkgs" ]]; then
        echo -e "following packages will be installed ...\n$pkgs"
        yay -Syu --noconfirm --needed $pkgs && echo "installation successfully" && return 0
        echo "Yay - installation failed"
    else
        echo "pkg files are empty"
    fi
    exit 1
}
# installs packages with flatpak
inst_flatpak_pkgs() {
    echo "installaing packages via Flatpak"
    # installing pkgs
    pkgs=$(grep -hvE "^\s*#|^\s*$" "$@")
    if [[ -n "$pkgs" ]]; then
        echo -e "following packages will be installed ...\n$pkgs"
        for pkg in "$pkgs"; do
            flatpak install -y flathub $pkg && echo "installation of *$pkg* successfully" && return 0
            echo "Flatpak - installation failed"
        done
    else
        echo "pkg files are empty"
    fi
    exit 1
}

# === setup services ===
# postgresql
psql_service() {
    local prefix="PostgreSQL setup was ..."
    if sudo su postgres -c "initdb -D /var/lib/postgres/data" 1> /dev/null && sudo systemctl enable --now postgresql 1> /dev/null; then
        echo "$prefix successful"
        return 0
    else
        echo "$prefix unsuccessful"
    fi
    exit 1
}
# opentabletdriver
otd_service() {
    systemctl --user enable --now opentabletdriver.service 1> /dev/null && return 0
    exit 1
}
# bluetooth
bt_service() {
    sudo systemctl enable --now bluetooth.service 1> /dev/null && return 0
    exit 1
}

# === kernel modules ===
# loading kernel modules
load_modules() {
    echo "loading modules file *$modules_list* ..."
    if [[ -f "$modules_list" ]]; then
    kernel_modules=$(grep -hvE "^\s*#|^\s*$" "$modules_list")
        if [[ -n "$kernel_modules" ]]; then
            echo "$kernel_modules"
            sudo modprobe $kernel_modules && return 0
        else
            echo "*$modules_list* is empty"
        fi
    else
        echo "*$modules_list* not found"
    fi
    exit 1
}

# === main ===
prefix="package & kernel modules ..."
if check_resource_files; then
    echo "$prefix found"
else
    echo "$prefix not found"
    exit 1
fi