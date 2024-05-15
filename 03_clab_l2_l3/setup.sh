#!/bin/bash
#

sudo clab deploy --reconfigure --topo l2-l3.clab.yml

docker exec clab-evpnl2-l3-leaf1 /setup.sh
docker exec clab-evpnl2-l3-leaf2 /setup.sh
docker exec clab-evpnl2-l3-spine /setup.sh
