#!/bin/bash
#

# Check if custom FRR+keepalived image exists, build if not
if ! docker image inspect frr-keepalived:latest &> /dev/null; then
    echo "Building frr-keepalived:latest Docker image..."
    docker build -t frr-keepalived:latest -f Dockerfile.frr-keepalived .
else
    echo "frr-keepalived:latest image already exists"
fi

sudo clab deploy --reconfigure --topo l2-l3.clab.yml

docker exec clab-evpnl2-l3-leaf1 /setup.sh
docker exec clab-evpnl2-l3-leaf2 /setup.sh
docker exec clab-evpnl2-l3-spine /setup.sh
