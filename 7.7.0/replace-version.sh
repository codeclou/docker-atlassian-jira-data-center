#!/bin/bash

for f in manage-jira-cluster-7.7.0.sh
do
  echo "Replacing version in $f"
  sed -i .bak 's/7\.6\.0/7.7.0/g' $f
  sed -i .bak 's/760/770/g' $f
done

rm -f *.bak
