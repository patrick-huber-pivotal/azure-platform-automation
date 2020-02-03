#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOT="$(realpath $DIR/..)"

echo "exporting director configuration with placeholders (ignore warning)"
om staged-director-config -r > $ROOT/vars/director.yml

echo "exporting director configiuration with secrets "
om staged-director-config --no-redact=true > $ROOT/vars/director-creds.yml
