#!/bin/bash

# env variables
export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$ROOT_DIR/inst.sh" # setup package requirements 
source "$ROOT_DIR/borgserver.sh" # borg backup & rsync as recovery method