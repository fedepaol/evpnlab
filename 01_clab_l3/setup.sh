#!/bin/bash
#

sudo clab deploy --reconfigure --topo direct.clab.yml

docker exec clab-evpnl3-leaf1 /setup.sh
docker exec clab-evpnl3-leaf2 /setup.sh
docker exec clab-evpnl3-spine /setup.sh
