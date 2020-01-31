#!/bin/bash

set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOT="$(realpath $DIR/..)"

echo "removing *creds.yml and *nocreds.yml files"
rm -rf $ROOT/config/*creds.yml
