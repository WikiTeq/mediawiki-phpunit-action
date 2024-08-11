#!/bin/sh -l

set -o pipefail

DEPENDENCIES=$1

echo -e "1:"
echo -e "$DEPENDENCIES"

echo $(pwd)
echo $(ls)