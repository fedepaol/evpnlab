#!/bin/bash

# Configuration
VM_NAME="storage"
VM_DISK="${VM_NAME}.qcow2"
CIDATA_ISO="${VM_NAME}-cidata.iso"

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "=== STORAGE VM Teardown Script ==="
echo "Working directory: $SCRIPT_DIR"

# Check if VM exists
if virsh dominfo "$VM_NAME" &> /dev/null 2>&1; then
    echo "Destroying VM $VM_NAME..."
    virsh destroy "$VM_NAME" 2>/dev/null || true
    virsh managedsave-remove "$VM_NAME" 2>/dev/null || true
    virsh undefine "$VM_NAME" --remove-all-storage --managed-save --nvram 2>/dev/null || true
    echo "VM $VM_NAME destroyed and undefined."
else
    echo "VM $VM_NAME does not exist."
fi

# Clean up VM-specific files (keep base image for reuse)
echo "Cleaning up VM files..."
rm -f "$VM_DISK" "$CIDATA_ISO"

echo ""
echo "=== Teardown Complete ==="
echo "VM and associated files have been cleaned up."
