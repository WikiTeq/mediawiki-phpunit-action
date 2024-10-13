#!/bin/sh -l

set -o pipefail

DEPENDENCIES=$1

echo -e "1:"
echo -e "$DEPENDENCIES"

echo $(pwd)
echo -e "Current"
echo -e "$(ls -la)"
echo -e "Up 1"
echo -e "$(ls -la ..)"
echo -e "Up 2"
echo -e "$(ls -la ../..)"
