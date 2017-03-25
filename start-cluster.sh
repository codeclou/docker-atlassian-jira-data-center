#!/bin/bash

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


docker kill jira-cluster-node1   # kill if already running
docker rm jira-cluster-node1     # remove named image if exists
docker run \
    --name jira-cluster-node1 \
    --net=jira-cluster \
    --net-alias=jira-cluster-node1 \
    --env NODE_NUMBER=1 \
    -v $(pwd)/jira-shared-home:/jira-shared-home \
    -d codeclou/docker-atlassian-jira-data-center:jiranode-software-7.3.3


docker kill jira-cluster-node2   # kill if already running
docker rm jira-cluster-node2     # remove named image if exists
docker run \
    --name jira-cluster-node2 \
    --net=jira-cluster \
    --net-alias=jira-cluster-node2 \
    --env NODE_NUMBER=2 \
    -v $(pwd)/jira-shared-home:/jira-shared-home \
    -d codeclou/docker-atlassian-jira-data-center:jiranode-software-7.3.3


docker kill jira-cluster-lb # kill if already running
docker rm jira-cluster-lb # if exists already
docker run \
    --name jira-cluster-lb \
    --net=jira-cluster \
    --net-alias=jira-cluster-lb \
    --env NODES=2 \
    -p 9980:9980 \
    -d codeclou/docker-atlassian-jira-data-center:loadbalancer

echo "================================"
echo "Cluster ready. Wait for JIRA nodes to startup (might take some minutes) and"
echo " "
echo "Goto http://jira-cluster-lb:9980"
echo " "
echo "do not forget to put '127.0.0.1 jira-cluster-lb' to /etc/hosts."
echo "================================"