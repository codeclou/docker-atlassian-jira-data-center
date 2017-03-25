#!/bin/bash

NODES=$1

if [ ! -n "${NODES}" ];
then
    echo "ERROR: Amount of nodes not set. Do 'bash stop-cluster.sh 4' to start four JIRA nodes"
    exit 1
else
    echo "INFO: Stopping ${NODES} JIRA nodes."
fi


docker kill jira-cluster-db

for i in $(seq 1 $NODES);
do
    docker kill jira-cluster-node${i}
done

docker kill jira-cluster-lb