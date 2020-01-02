#!/usr/bin/env bash

echo "setting strict script"

set -xuo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; df -h; exit $s' ERR
IFS=$'\n\t'
set -x

echo "strict setup completed"