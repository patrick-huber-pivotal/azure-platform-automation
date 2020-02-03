#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOT="$(realpath $DIR/..)"

echo "setting tile creds"
export PRODUCTS=`cat $ROOT/config/PRODUCTS`
for PRODUCT in $PRODUCTS
do
    echo "setting credentials for $PRODUCT"
    ymldiff -f json $ROOT/config/$PRODUCT-nocreds.yml $ROOT/config/$PRODUCT-creds.yml | \
    jq '
    [  
       .Differences[] 
       | { 
           placeholder: (
             if (.Path | length) > 4 then
               .Path[1]+"_"+.Path[3]+"_"+.Path[4] 
             else 
               .Path[1] 
             end) , 
           credential: (
             if (.Path | length) > 2 then
               .To 
             else 
               .To.value 
             end) } 
       | .
    ]' | \
    jq '
    [
      .[] 
      | { 
          placeholder: (.placeholder | split(".") | .[1:] | join("_") ), 
          credential: .credential }
    ]' | \
    jq '
    .[] 
    | "credhub set -n /concourse/main/"+ .placeholder + " --type json --value " + (.credential | tostring | @sh )' \
      -r > /tmp/script.sh
    chmod +x /tmp/script.sh
    source /tmp/script.sh 
    rm /tmp/script.sh 
done 

