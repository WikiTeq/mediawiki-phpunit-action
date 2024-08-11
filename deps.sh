#!/bin/sh -l

set -o pipefail

DEPENDENCIES=$1
FORMATTED=$1

echo -e "1:"
echo -e $DEPENDENCIES

echo -e "2:"
echo -e $FORMATTED
