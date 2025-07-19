#!/bin/bash

# env variables
export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # path of source

source "$ROOT_DIR/inst.sh" # setup package requirements 
source "$ROOT_DIR/rsync.sh" # copy backup files