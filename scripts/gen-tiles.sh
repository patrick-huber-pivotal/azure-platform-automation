#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOT="$(realpath $DIR/..)"

# get the list of products
om staged-products -f json | jq '.[].name' -r > $ROOT/config/PRODUCTS
export PRODUCTS=`cat $ROOT/config/PRODUCTS`

for product in $PRODUCTS
do
   echo "exporting config for $product"
   om staged-config -p $product > "$ROOT/config/$product-nocreds.yml" &
   
   echo "exporting placeholder config for $product"
   om staged-config -r -p $product > "$ROOT/config/$product.yml" &

   echo "exporting credential config for $product"
   om staged-config -c -p $product > "$ROOT/config/$product-creds.yml" &

   echo "waiting for $product exports to complete"
   wait 
done
