#!/bin/bash

set -e

umask u+rxw,g+rwx,o-rwx

#
# GENERATE CLUSTER CONF
#
env | j2  --format=env /work-private/cluster.properties.jinja2 > /jira-home/cluster.properties

exec "$@"