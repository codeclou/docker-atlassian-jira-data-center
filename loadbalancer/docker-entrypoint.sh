#!/bin/bash

set -e

umask u+rxw,g+rwx,o-rwx

#
# GENERATE LOADBALANCER CONFIG BASED ON AMOUNT OF NODES
#
echo "generating loadbalancer config for $NODES nodes"
env | j2  --format=env /work-private/loadbalancer-virtual-host.conf.jinja2 > /work-private/loadbalancer-virtual-host.conf


exec "$@"
