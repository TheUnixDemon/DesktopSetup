#!/bin/bash

# env variables
export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# sudo temp for unattended install
keepalive_sudo() {
    if sudo -v; then
        {
            while true; do
                sleep 60
                sudo -n true
            done
        } 2>/dev/null &
        keepalive=$!
        echo "sudo keep-alive started (PID $keepalive)"
        return 0
    else
        echo "sudo authentication failed"
        return 1
    fi
}

# keep alive sudo permission
keepalive_sudo

# execute installation & recovery
source "$ROOT_DIR/inst.sh" # setup package requirements 
source "$ROOT_DIR/borgserver.sh" # borg backup & rsync as recovery method

# undo keep alive sudo permission
if [[ -n "$keepalive" ]] && kill -0 "$keepalive" 2>/dev/null; then
    kill "$keepalive"
fi