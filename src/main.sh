#!/bin/bash

# env variables
export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # path of source

# setup package requirements 
source "$ROOT_DIR/inst.sh"

