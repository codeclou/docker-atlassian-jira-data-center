#!/bin/bash

NODES=$1

if [ ! -n "${NODES}" ];
then
    echo "ERROR: Amount of nodes not set. Do 'bash start-cluster.sh 4' to start four JIRA nodes"
    exit 1
else
    echo "INFO: Starting ${NODES} JIRA nodes."
fi


#
# START A JIRA-DATA CENTER CLUSTER WITH
# two JIRA nodes, one db, one loadbalancer
#

docker network rm jira-cluster
docker network create jira-cluster

docker pull codeclou/docker-atlassian-jira-data-center:jiranode-software-7.3.3
docker pull codeclou/docker-atlassian-jira-data-center:loadbalancer


docker kill jira-cluster-db # if exists already
docker rm jira-cluster-db # if exists already
docker run \
    --name jira-cluster-db \
    --net=jira-cluster \
    --net-alias=jira-cluster-db \
    -e POSTGRES_PASSWORD=jira \
    -e POSTGRES_USER=jira \
    -d postgres:9.4

sleep 5

rm -rf $(pwd)/jira-shared-home/* # clean shared jira-home if present


for i in $(seq 1 $NODES);
do
    docker kill jira-cluster-node${i}   # kill if already running
    docker rm jira-cluster-node${i}     # remove named image if exists
    docker run \
        --name jira-cluster-node${i} \
        --net=jira-cluster \
        --net-alias=jira-cluster-node${i} \
        --env NODE_NUMBER=${i} \
        -v $(pwd)/jira-shared-home:/jira-shared-home \
        -d codeclou/docker-atlassian-jira-data-center:jiranode-software-7.3.3
done


docker kill jira-cluster-lb  # kill if already running
docker rm jira-cluster-lb    # if exists already
docker run \
    --name jira-cluster-lb \
    --net=jira-cluster \
    --net-alias=jira-cluster-lb \
    --env NODES=${NODES} \
    -p 9980:9980 \
    -d codeclou/docker-atlassian-jira-data-center:loadbalancer


echo "================================"
echo "Cluster ready. Wait for JIRA nodes to startup (might take some minutes) and"
echo " "
echo "Goto http://jira-cluster-lb:9980"
echo " "
echo "do not forget to put '127.0.0.1 jira-cluster-lb' to /etc/hosts."
echo "================================"