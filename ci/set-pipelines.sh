#!/bin/bash

# get the current script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "setting dependencies pipeline"
fly -t dell set-pipeline \
   -p retrieve-platform-dependencies \
   -c $DIR/dependencies.yml \
   -l $DIR/vars.yml

echo "setting installation pipeline"
fly -t dell set-pipeline \
   -p installation \
   -c $DIR/installation.yml \
   -l $DIR/vars.yml
