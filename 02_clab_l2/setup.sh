#!/bin/bash
#

sudo clab deploy --reconfigure --topo l2.clab.yml

docker exec clab-evpnl2-leaf1 /setup.sh
docker exec clab-evpnl2-leaf2 /setup.sh
docker exec clab-evpnl2-spine /setup.sh
