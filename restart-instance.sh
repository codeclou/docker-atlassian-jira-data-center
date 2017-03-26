#!/bin/bash

NODES=$2
NODE=$1

#
# USAGE: bash restart-instance.sh 1 2
#
# to restart instance 1 of four JIRA nodes
#

if [ ! -n "${NODES}" ];
then
    echo "ERROR: Amount of nodes not set. Do 'bash restart-instance.sh 1 4' to restart instance 1 of four JIRA nodes"
    exit 1
else
    echo "INFO: Stopping jira-cluster-node${NODE}, restarting and adjusting loadbalancer."
fi


docker kill jira-cluster-node${NODE}
docker rm jira-cluster-node${NODE}     # remove named image if exists
docker run \
    --name jira-cluster-node${NODE} \
    --net=jira-cluster \
    --net-alias=jira-cluster-node${NODE} \
    --env NODE_NUMBER=${NODE} \
    -v $(pwd)/jira-shared-home:/jira-shared-home \
    -d codeclou/docker-atlassian-jira-data-center:jiranode-software-7.3.3

docker kill jira-cluster-lb  # kill if already running
docker rm jira-cluster-lb    # if exists already
docker run \
    --name jira-cluster-lb \
    --net=jira-cluster \
    --net-alias=jira-cluster-lb \
    --env NODES=${NODES} \
    -p 9980:9980 \
    -d codeclou/docker-atlassian-jira-data-center:loadbalancer