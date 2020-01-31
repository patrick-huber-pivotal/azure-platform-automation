#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOT="$(realpath $DIR/..)"

# get the list of products
om staged-products -f json | jq '.[].name' -r > $ROOT/config/PRODUCTS
export PRODUCTS=`cat $ROOT/config/PRODUCTS`

queue=/tmp/queue.txt
rm $queue
for product in $PRODUCTS
do
   echo "queueing export config for $product"
   echo -e "om staged-config -p $product > \x22$ROOT/config/$product-nocreds.yml\x22" >> $queue
   
   echo "queueing export placholder config for $product"
   echo -e "om staged-config -r -p $product > \x22$ROOT/config/$product.yml\x22" >> $queue

   echo "queueing export credential config for $product"
   echo -e "om staged-config -c -p $product > \x22$ROOT/config/$product-creds.yml\x22" >> $queue

done

workers=3
count=0
pids=()
while read -r line; do
   while [ "$count" -eq "$workers" ]; do
     sleep 1
     for pid in $pids; do
       # check job queue if any jobs are empty
       if ! ps -p $pid >&-; then
         ((count--))
       fi 
     done
   done 
   echo "running: $line"
   $line &
   $pids+=$(!$)
   ((count++))
done < ${queue}

# cleanup job file 
rm $queue
