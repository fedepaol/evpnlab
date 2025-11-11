#!/bin/bash
#

sudo clab deploy --reconfigure --topo multitenant.clab.yml

docker exec clab-evpnl3-leaf1 /setup.sh
docker exec clab-evpnl3-leaf2 /setup.sh
docker exec clab-evpnl3-borderleaf /setup.sh
docker exec clab-evpnl3-storageleaf /setup.sh
docker exec clab-evpnl3-spine /setup.sh
