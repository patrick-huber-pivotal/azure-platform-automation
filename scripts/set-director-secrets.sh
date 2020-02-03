#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOT="$(realpath $DIR/..)"

echo "setting director creds"
ymldiff -f json <(bosh int $ROOT/vars/director.yml -o $ROOT/ops/director-placeholders.yml ) $ROOT/vars/director-creds.yml | 
jq '
  .Differences[]
  | "credhub set -n /concourse/main/" + ( .From | gsub("[(]{2}|[)]{2}";"") ) + " --type value --value " + (.To | tostring | @sh )
' -r | \
sed $'s/\r//' > /tmp/script.sh

chmod +x /tmp/script.sh
source /tmp/script.sh
rm /tmp/script.sh

