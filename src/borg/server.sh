#!/bin/bash

# === vars ===
[[ -v BORG_RSH && -f "$SSH_KEYFILE" ]] && export BORG_RSH