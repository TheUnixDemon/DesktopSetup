#!/bin/bash

# env variables
export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
        echo "sudo keep-alive started"
        return 0
    else
        echo "sudo authentication failed"
        return 1
    fi
}

# keep alive sudo permission
keep_alive_sudo

# execute installation & recovery
source "$ROOT_DIR/inst.sh" # setup package requirements 
source "$ROOT_DIR/borgserver.sh" # borg backup & rsync as recovery method

# undo keep alive sudo permission
if [[ -n "$keep_alive" ]] && kill -0 "$keep_alive" 2>/dev/null; then
    kill "$keep_alive"
fi