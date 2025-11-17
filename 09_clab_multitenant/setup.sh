#!/bin/bash
#

# Configuration
BRIDGE_NAME="SERVER1"

# Create bridge if it doesn't exist
if ! ip link show "$BRIDGE_NAME" &> /dev/null; then
    echo "Creating bridge $BRIDGE_NAME..."
    sudo ip link add name "$BRIDGE_NAME" type bridge
    sudo ip link set "$BRIDGE_NAME" up
    echo "Bridge $BRIDGE_NAME created and enabled"
else
    echo "Bridge $BRIDGE_NAME already exists"
    # Ensure it's up
    sudo ip link set "$BRIDGE_NAME" up
fi

# Deploy containerlab topology
sudo clab deploy --reconfigure --topo multitenant.clab.yml

#docker exec clab-evpnl3-leaf1 /setup.sh
#docker exec clab-evpnl3-leaf2 /setup.sh
#docker exec clab-evpnl3-borderleaf /setup.sh
#docker exec clab-evpnl3-storageleaf /setup.sh
docker exec clab-evpnl3-spine /setup.sh
pusdh SERVER1_VM
setup.sh
popd
