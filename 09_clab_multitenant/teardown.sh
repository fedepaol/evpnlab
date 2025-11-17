#!/bin/bash
set -e

echo "=== Lab Teardown Script ==="

# Configuration
SERVER1_BRIDGE="SERVER1"
STORAGE_BRIDGE="STORAGE"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Teardown VMs first
echo ""
echo "Step 1: Tearing down VMs..."

echo "  Tearing down SERVER1 VM..."
if [ -f "$SCRIPT_DIR/SERVER1_VM/teardown.sh" ]; then
    pushd "$SCRIPT_DIR/SERVER1_VM" > /dev/null
    ./teardown.sh
    popd > /dev/null
else
    echo "  Warning: SERVER1_VM/teardown.sh not found, skipping"
fi

echo "  Tearing down STORAGE VM..."
if [ -f "$SCRIPT_DIR/STORAGE_VM/teardown.sh" ]; then
    pushd "$SCRIPT_DIR/STORAGE_VM" > /dev/null
    ./teardown.sh
    popd > /dev/null
else
    echo "  Warning: STORAGE_VM/teardown.sh not found, skipping"
fi

# Destroy containerlab topology
echo ""
echo "Step 2: Destroying containerlab topology..."
sudo clab destroy --topo multitenant.clab.yml --cleanup

# Remove bridges if they exist
echo ""
echo "Step 3: Removing bridges..."

if ip link show "$SERVER1_BRIDGE" &> /dev/null; then
    sudo ip link set "$SERVER1_BRIDGE" down
    sudo ip link delete "$SERVER1_BRIDGE" type bridge
    echo "  Bridge $SERVER1_BRIDGE removed"
else
    echo "  Bridge $SERVER1_BRIDGE does not exist, skipping"
fi

if ip link show "$STORAGE_BRIDGE" &> /dev/null; then
    sudo ip link set "$STORAGE_BRIDGE" down
    sudo ip link delete "$STORAGE_BRIDGE" type bridge
    echo "  Bridge $STORAGE_BRIDGE removed"
else
    echo "  Bridge $STORAGE_BRIDGE does not exist, skipping"
fi

echo ""
echo "=== Teardown Complete ==="
echo "All lab components have been cleaned up."
