#!/bin/bash
set -e

echo "=== Lab Teardown Script ==="

# Configuration
BRIDGE_NAME="SERVER1"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Teardown VM first
echo ""
echo "Step 1: Tearing down SERVER1 VM..."
if [ -f "$SCRIPT_DIR/SERVER1_VM/teardown.sh" ]; then
    pushd "$SCRIPT_DIR/SERVER1_VM" > /dev/null
    sudo ./teardown.sh
    popd > /dev/null
else
    echo "Warning: SERVER1_VM/teardown.sh not found, skipping VM teardown"
fi

# Destroy containerlab topology
echo ""
echo "Step 2: Destroying containerlab topology..."
sudo clab destroy --topo multitenant.clab.yml --cleanup

# Remove bridge if it exists
echo ""
echo "Step 3: Removing bridge $BRIDGE_NAME..."
if ip link show "$BRIDGE_NAME" &> /dev/null; then
    sudo ip link set "$BRIDGE_NAME" down
    sudo ip link delete "$BRIDGE_NAME" type bridge
    echo "Bridge $BRIDGE_NAME removed"
else
    echo "Bridge $BRIDGE_NAME does not exist, skipping"
fi

echo ""
echo "=== Teardown Complete ==="
echo "All lab components have been cleaned up."
