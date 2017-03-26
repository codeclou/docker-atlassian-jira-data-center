#!/bin/bash

####################################################################################
# MIT License
# Copyright (c) 2017 Bernhard Grünewaldt
# See https://github.com/codeclou/docker-atlassian-jira-data-center/blob/master/LICENSE
####################################################################################

set -e

####################################################################################
#
# CONFIG
#
####################################################################################

# JIRA_SOFTWARE_VERSION
#    do not change unless a pre-build image is available on docker hub
#    check: https://hub.docker.com/r/codeclou/docker-atlassian-jira-data-center/tags/
JIRA_SOFTWARE_VERSION="7.3.3"

# MULTICAST
#    Multicast is activated by default
MULTICAST="true"

####################################################################################
#
# COLORS
#
####################################################################################

export CLICOLOR=1
C_RED='\x1B[31m'
C_CYN='\x1B[96m'
C_GRN='\x1B[32m'
C_MGN='\x1B[35m'
C_RST='\x1B[39m'

####################################################################################
#
# FUNCTIONS
#
####################################################################################

# Used to be able to use pass-by-reference in bash
#
#
return_by_reference() {
    if unset -v "$1"; then
        eval $1=\"\$2\"
    fi
}

# Returns 1 if the container is running and 0 if not
#
# @usage `_is_named_container_running 'foo' $result` passed variable `result` contains return value
#
# @param $1 {string} name or name-chunk of container
# @param $2 {int} return value passByReference
function _is_named_container_running {
    local ret_value=$(docker ps --format '{{.ID}}' --filter "name=${1}" | wc -l | awk '{print $1}')

    local "$2" && return_by_reference $2 $ret_value
}

# Kill and remove an existing named container
#
# @param $1 {string} the container name or part of it
function _kill_and_remove_named_instance_if_exists {
    container_name=$1
    # KILL
    named_container_running_result=-1
    _is_named_container_running ${container_name} named_container_running_result
    if (( named_container_running_result == 1 )) # arithmetic brackets ... woohoo
    then
        echo -e $C_CYN">> docker kill ........:${C_RST}${C_GRN} Killing${C_RST}   - Named container ${container_name} is running."
        docker kill ${container_name}
    else
        echo -e $C_CYN">> docker kill ........:${C_RST}${C_MGN} Skipping${C_RST}  - Named container ${container_name} is not running."
    fi
    # DELETE
    named_container_exists=$(docker ps --all --format '{{.Names}}' --filter "name=${container_name}" | wc -l | awk '{print $1}')
    if (( named_container_exists == 1 )) # arithmetic brackets ... woohoo
    then
        echo -e $C_CYN">> docker rm ..........:${C_RST}${C_GRN} Deleting${C_RST}  - Named container ${container_name} does exist."
        docker rm ${container_name}
    else
        echo -e $C_CYN">> docker rm ..........:${C_RST}${C_MGN} Skipping${C_RST}  - Named container ${container_name} does not exist."
    fi
}

# Start the loadbalancer instance
#
# @param $1 {integer} amount of jiranodes
function start_instance_loadbalancer {
    echo -e $C_CYN">> docker run .........:${C_RST}${C_GRN} Starting${C_RST}  - Starting instance jira-cluster-lb."
    docker run \
        --name jira-cluster-lb \
        --net=jira-cluster \
        --net-alias=jira-cluster-lb \
        --env NODES=${1} \
        -p 9980:9980 \
        -d codeclou/docker-atlassian-jira-data-center:loadbalancer
}

# Kill the loadbalancer instance
#
#
function kill_instance_loadbalancer {
    _kill_and_remove_named_instance_if_exists jira-cluster-lb
}

# Start the database instance
#
#
function start_instance_database {
    echo -e $C_CYN">> docker run .........:${C_RST}${C_GRN} Starting${C_RST}  - Starting instance jira-cluster-db."
    docker run \
        --name jira-cluster-db \
        --net=jira-cluster \
        --net-alias=jira-cluster-db \
        -e POSTGRES_PASSWORD=jira \
        -e POSTGRES_USER=jira \
        -d postgres:9.4
}

# Kill the database instance
#
#
function kill_instance_database {
    _kill_and_remove_named_instance_if_exists jira-cluster-db
}

# Start a jiranode instance
#
# @param $1 {int} node ID
function start_instance_jiranode {
    echo -e $C_CYN">> docker run .........:${C_RST}${C_GRN} Starting${C_RST}  - Starting instance jira-cluster-node${1}."
    docker run \
        --name jira-cluster-node${1} \
        --net=jira-cluster \
        --net-alias=jira-cluster-node${1} \
        --env NODE_NUMBER=${1} \
        --env MULTICAST=${MULTICAST} \
        -v $(pwd)/jira-shared-home:/jira-shared-home \
        -d codeclou/docker-atlassian-jira-data-center:jiranode-software-${JIRA_SOFTWARE_VERSION}
}

# Kill a jiranode instance
#
# @param $1 {int} node ID
function kill_instance_jiranode {
    _kill_and_remove_named_instance_if_exists jira-cluster-node${1}
}

# Cleans the jira shared-home
#
#
function clean_jiranode_shared_home {
    echo -e $C_CYN">> clean shared home ..:${C_RST}${C_GRN} Deleting${C_RST}  - Deleting contents of jira-shared-home: $(pwd)/jira-shared-home/."
    rm -rf $(pwd)/jira-shared-home/* # clean shared jira-home if present
}

# Pulls the latest docker images from docker hub
#
#
function pull_latest_images {
    echo -e $C_CYN">> docker pull ........:${C_RST}${C_GRN} Pulling${C_RST}   - Pulling latest images from Docker Hub."
    docker pull codeclou/docker-atlassian-jira-data-center:jiranode-software-${JIRA_SOFTWARE_VERSION}
    docker pull codeclou/docker-atlassian-jira-data-center:loadbalancer
}

# Creates a network for cluster
#
#
function create_network {
    network_exists=$(docker network ls --filter 'name=jira-cluster' --format '{{.Name}}' | wc -l | awk '{print $1}')
    if (( network_exists == 1 )) # arithmetic brackets ... woohoo
    then
        echo -e $C_CYN">> docker network .....:${C_RST}${C_MGN} Skipping${C_RST}  - Network jira-cluster exists already."
    else
        echo -e $C_CYN">> docker network .....:${C_RST}${C_GRN} Creating${C_RST}  - Creating network jira-cluster."
        docker network create jira-cluster
    fi
}

# Returns the count of running jiranode instances
#
# @usage
#     result=-1
#     get_running_jiranode_count result
#
# @param $1 {int} return value passByReference
function get_running_jiranode_count {
    local ret_value=-1
    _is_named_container_running "jira-cluster-node" ret_value

    local "$1" && return_by_reference $1 $ret_value
}

# Returns an array of docker image names of running jiranode instances
#
# @usage
#     result=""
#     get_running_jiranode_name_array result
#
# @param $1 {string} return value passByReference in form of "node1 node2 node"
function get_running_jiranode_name_array {
    local instance_names_string_newlines=$(docker ps --format '{{.Names}}' --filter "name=jira-cluster-node")
    local instance_names_string_oneline=$(echo $instance_names_string_newlines | tr "\n" " ")
    local ret_value=$instance_names_string_oneline

    local "$1" && return_by_reference $1 "$ret_value"
}

# Kills and removes all jira-cluster-node* instances if present
#
#
function kill_all_running_jiranodes {
    # NOTE: We must get all names to kill them, since e.g. node1,node4,node5 could be running
    #       so we cannot just use a dumb counter starting from 1!
    local running_jiranode_count=0
    get_running_jiranode_count running_jiranode_count
    if (( running_jiranode_count > 0 )) # arithmetic brackets ... woohoo
    then
        echo -e $C_CYN">> docker kill nodes ..:${C_RST}${C_GRN} Killing${C_RST}   - Killing all running jira-cluster-node* instances."
        local running_instance_names=""
        get_running_jiranode_name_array running_instance_names
        local running_instance_names_array=($running_instance_names)
        for running_instance_name in "${running_instance_names_array[@]}"
        do
           _kill_and_remove_named_instance_if_exists ${running_instance_name}
        done
    else
        echo -e $C_CYN">> docker kill nodes ..:${C_RST}${C_MGN} Skipping${C_RST}  - No running jira-cluster-node* instances present."
    fi
}

# Prints info
#
#
function print_cluster_ready_info {
    echo -e $C_CYN">> ----------------------------------------------------------------------------------------------------"$C_RST
    echo -e $C_CYN">> info ...............:${C_RST}${C_GRN} Ready${C_RST}     - Wait for JIRA nodes to startup, might take some minutes."
    echo -e $C_CYN">> info ...............:${C_RST}${C_GRN} http://jira-cluster-lb:9980${C_RST} "
    echo -e $C_CYN">> info ...............:${C_RST} Do not forget to:"
    echo -e $C_CYN">> info ...............:${C_RST}   [1] put '127.0.0.1 jira-cluster-lb' to /etc/hosts."
    echo -e $C_CYN">> info ...............:${C_RST}   [2] enable IP Forwarding to support multicast."
    echo -e $C_CYN">> ----------------------------------------------------------------------------------------------------"$C_RST
}

####################################################################################
#
# PARAMETERS AND BANNER
#
####################################################################################

while [[ $# > 1 ]]
do
key="$1"
case $key in
    -s|--scale)
    SCALE="$2"
    shift
    ;;
    -m|--multicast)
    MULTICAST_PARAM="$2"
    shift
    ;;
    -a|--action)
    ACTION="$2"
    shift
    ;;
    *)
       # unknown option
    ;;
esac
shift
done

echo ""
echo -e $C_MGN'      __  ___                                ________           __           '$C_RST
echo -e $C_MGN'     /  |/  /___ _____  ____ _____ ____     / ____/ /_  _______/ /____  _____'$C_RST
echo -e $C_MGN'    / /|_/ / __ `/ __ \/ __ `/ __ `/ _ \   / /   / / / / / ___/ __/ _ \/ ___/'$C_RST
echo -e $C_MGN'   / /  / / /_/ / / / / /_/ / /_/ /  __/  / /___/ / /_/ (__  ) /_/  __/ /    '$C_RST
echo -e $C_MGN'  /_/  /_/\__,_/_/ /_/\__,_/\__, /\___/   \____/_/\__,_/____/\__/\___/_/     '$C_RST
echo -e $C_MGN'                           /____/                                            '$C_RST
echo ""
echo -e $C_MGN'  Manage local JIRA® Data Center cluster during Plugin development with Docker'$C_RST
echo -e $C_MGN'  v0.0.1 - https://github.com/codeclou/docker-atlassian-jira-data-center'$C_RST
echo -e $C_MGN'  ------'$C_RST
echo ""

EXIT=0
if [ ! $SCALE ]
then
    echo -e $C_RED">> param error ........: Please specify scale as parameter -s or --scale. E.g. --scale 3"$C_RST
    EXIT=1
fi
if [ ! $ACTION ]
then
    echo -e $C_RED">> param error ........: Please specify action as parameter -a or --action"$C_RST
    EXIT=1
fi
if [ ! $MULTICAST_PARAM ]
then
    MULTICAST="true"
    echo -e $C_CYN">> config .............:${C_RST}${C_GRN} Multicast${C_RST} - using multicast='true' by default."$C_RST
    echo ""
else
    MULTICAST="false"
    echo -e $C_CYN">> config .............:${C_RST}${C_GRN} Multicast${C_RST} - using multicast='false' by user choice."$C_RST
    echo ""
fi

if [ $EXIT -eq 1 ]
then
    echo -e $C_RED">> exit ...............: quitting because of previous errors"$C_RST
    echo ""
    exit 1
fi

####################################################################################
#
# CLUSTER LOGIC
#
####################################################################################

pull_latest_images
echo ""

if [ "$ACTION" == "create" ]
then
    echo -e $C_CYN">> action .............:${C_RST}${C_GRN} Creating${C_RST} - Creating new cluster and destroying existing if exists"$C_RST
    echo ""

    create_network
    echo ""

    clean_jiranode_shared_home
    echo ""

    kill_all_running_jiranodes
    echo ""

    kill_instance_database
    start_instance_database
    echo ""

    kill_instance_loadbalancer
    start_instance_loadbalancer $SCALE
    echo ""

    for (( node_id=1; node_id<=$SCALE; node_id++ ))
    do
        kill_instance_jiranode $node_id
        start_instance_jiranode $node_id
        echo ""
    done
    echo ""

    print_cluster_ready_info
    echo ""
fi


