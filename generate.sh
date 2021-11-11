#! /bin/bash

set -Ee

function exit {
  echo "Exiting"
  # sleep 10 # Just to allow fluentd gathering logs before termination
}

trap exit EXIT

openapi-generator generate -g html2 -t /templates -o /local/o -i /local/m.yaml
