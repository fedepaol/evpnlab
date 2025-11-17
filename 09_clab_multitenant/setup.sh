#!/bin/bash
#

# Configuration
SERVER1_BRIDGE="SERVER1"
STORAGE_BRIDGE="STORAGE"

# Create SERVER1 bridge if it doesn't exist
if ! ip link show "$SERVER1_BRIDGE" &> /dev/null; then
    echo "Creating bridge $SERVER1_BRIDGE..."
    sudo ip link add name "$SERVER1_BRIDGE" type bridge
    sudo ip link set "$SERVER1_BRIDGE" up
    echo "Bridge $SERVER1_BRIDGE created and enabled"
else
    echo "Bridge $SERVER1_BRIDGE already exists"
    # Ensure it's up
    sudo ip link set "$SERVER1_BRIDGE" up
fi

# Create STORAGE bridge if it doesn't exist
if ! ip link show "$STORAGE_BRIDGE" &> /dev/null; then
    echo "Creating bridge $STORAGE_BRIDGE..."
    sudo ip link add name "$STORAGE_BRIDGE" type bridge
    sudo ip link set "$STORAGE_BRIDGE" up
    echo "Bridge $STORAGE_BRIDGE created and enabled"
else
    echo "Bridge $STORAGE_BRIDGE already exists"
    # Ensure it's up
    sudo ip link set "$STORAGE_BRIDGE" up
fi

# Whitelist bridges in QEMU configuration
QEMU_BRIDGE_CONF="/etc/qemu-kvm/bridge.conf"
if [ ! -f "$QEMU_BRIDGE_CONF" ]; then
    QEMU_BRIDGE_CONF="/etc/qemu/bridge.conf"
fi

echo "Whitelisting bridges in QEMU configuration..."
sudo mkdir -p "$(dirname "$QEMU_BRIDGE_CONF")"
sudo touch "$QEMU_BRIDGE_CONF"

# Add SERVER1 bridge if not already present
if ! sudo grep -q "^allow $SERVER1_BRIDGE" "$QEMU_BRIDGE_CONF" 2>/dev/null; then
    echo "allow $SERVER1_BRIDGE" | sudo tee -a "$QEMU_BRIDGE_CONF" > /dev/null
    echo "Added $SERVER1_BRIDGE to QEMU bridge whitelist"
else
    echo "$SERVER1_BRIDGE already whitelisted in QEMU config"
fi

# Add STORAGE bridge if not already present
if ! sudo grep -q "^allow $STORAGE_BRIDGE" "$QEMU_BRIDGE_CONF" 2>/dev/null; then
    echo "allow $STORAGE_BRIDGE" | sudo tee -a "$QEMU_BRIDGE_CONF" > /dev/null
    echo "Added $STORAGE_BRIDGE to QEMU bridge whitelist"
else
    echo "$STORAGE_BRIDGE already whitelisted in QEMU config"
fi

# Deploy containerlab topology
sudo clab deploy --reconfigure --topo multitenant.clab.yml

#docker exec clab-evpnl3-leaf1 /setup.sh
#docker exec clab-evpnl3-leaf2 /setup.sh
#docker exec clab-evpnl3-borderleaf /setup.sh
#docker exec clab-evpnl3-storageleaf /setup.sh
docker exec clab-evpnl3-spine /setup.sh
pushd SERVER1_VM
./setup.sh
popd
pushd STORAGE_VM
./setup.sh
popd
