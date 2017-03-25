#!/bin/bash

#
# START A JIRA-DATA CENTER CLUSTER WITH
# two JIRA nodes, one db, one loadbalancer
#


docker kill jira-cluster-db # if exists already
docker rm jira-cluster-db # if exists already
docker run \
    --name jira-cluster-db \
    -e POSTGRES_PASSWORD=jira \
    -e POSTGRES_USER=jira \
    -d postgres:9.4

sleep 5

rm -rf $(pwd)/jira-shared-home/* # clean shared jira-home if present


docker kill jira-cluster-node1   # kill if already running
docker rm jira-cluster-node1     # remove named image if exists
docker run \
    --name jira-cluster-node1 \
    --link jira-cluster-db \
    --add-host jira-cluster-node1:127.0.0.1 \
    --env NODE_NUMBER=1 \
    -v $(pwd)/jira-shared-home:/jira-shared-home \
    -d codeclou/docker-atlassian-jira-data-center:jiranode-software-7.3.3


docker kill jira-cluster-node2   # kill if already running
docker rm jira-cluster-node2     # remove named image if exists
docker run \
    --name jira-cluster-node2 \
    --link jira-cluster-db \
    --add-host jira-cluster-node1:127.0.0.1 \
    --env NODE_NUMBER=2 \
    -v $(pwd)/jira-shared-home:/jira-shared-home \
    -d codeclou/docker-atlassian-jira-data-center:jiranode-software-7.3.3


docker kill jira-cluster-lb # kill if already running
docker rm jira-cluster-lb # if exists already
docker run \
    --name jira-cluster-lb \
    --link jira-cluster-node1 \
    --link jira-cluster-node2 \
    --env NODES=2 \
    -p 9980:9999 \
    -d codeclou/docker-atlassian-jira-data-center:loadbalancer

echo "Cluster ready: Goto http://localhost:9980"