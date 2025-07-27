#!/bin/bash

# === vars ===
PKGS_WORKING_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # location env

# === func ===
# installing packages with pacman, yay & flatpak
install_pkgs(
    inst_pacman_pkgs $nvidia_pkgs $pacman_pkgs
    inst_yay_pkgs $yay_pkgs
    inst_flatpak_pkgs $flatpak_pkgs
)
# setup services
setup_services() {
    psql_service
    otd_service
    bt_service
}

# === main ===
# installation preparation
source "$PKGS_WORKING_DIR/install.sh"