#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
sudo clab deploy --reconfigure --topo l2-l3.clab.yml

docker exec clab-evpnl2-l3-svd-leaf1 /setup.sh
docker exec clab-evpnl2-l3-svd-leaf2 /setup.sh
docker exec clab-evpnl2-l3-svd-spine /setup.sh
