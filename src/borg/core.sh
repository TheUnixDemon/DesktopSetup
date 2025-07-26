#!/bin/bash

# === vars ===
BORG_WORKING_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # location env
borg_conf_file="$BORG_WORKING_DIR/conf/conf.sh"

# === main ===
# loading borg configuration
if ! source "$borg_conf_file"; then
    echo "failed to load configuration *$borg_conf_file*; abort"
    exit 1
fi

# loading server script
source "$BORG_WORKING_DIR/server.sh"