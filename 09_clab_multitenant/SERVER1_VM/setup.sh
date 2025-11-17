#!/bin/bash
set -e

# Configuration
VM_NAME="server1"
BRIDGE_NAME="SERVER1"
FEDORA_VERSION="41"
IMAGE_URL="https://download.fedoraproject.org/pub/fedora/linux/releases/${FEDORA_VERSION}/Cloud/x86_64/images/Fedora-Cloud-Base-Generic.x86_64-${FEDORA_VERSION}-1.4.qcow2"
BASE_IMAGE="Fedora-Cloud-Base-${FEDORA_VERSION}.qcow2"
VM_DISK="${VM_NAME}.qcow2"
CIDATA_ISO="${VM_NAME}-cidata.iso"

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "=== SERVER1 VM Setup Script ==="
echo "Working directory: $SCRIPT_DIR"

# Download Fedora cloud image if not present
if [ ! -f "$BASE_IMAGE" ]; then
    echo "Downloading Fedora Cloud image..."
    curl -L -o "$BASE_IMAGE" "$IMAGE_URL"
else
    echo "Fedora Cloud image already exists: $BASE_IMAGE"
fi

# Create VM disk from base image
if [ ! -f "$VM_DISK" ]; then
    echo "Creating VM disk from base image..."
    cp "$BASE_IMAGE" "$VM_DISK"
    qemu-img resize "$VM_DISK" 20G
else
    echo "VM disk already exists: $VM_DISK"
fi

# Create cloud-init ISO
echo "Creating cloud-init ISO..."
if command -v genisoimage &> /dev/null; then
    genisoimage -output "$CIDATA_ISO" \
        -volid cidata -joliet -rock \
        user-data meta-data
elif command -v mkisofs &> /dev/null; then
    mkisofs -output "$CIDATA_ISO" \
        -volid cidata -joliet -rock \
        user-data meta-data
else
    echo "Error: Neither genisoimage nor mkisofs found. Please install one of them."
    exit 1
fi

# Check if bridge exists
if ! ip link show "$BRIDGE_NAME" &> /dev/null; then
    echo "WARNING: Bridge $BRIDGE_NAME does not exist yet."
    echo "Please make sure containerlab is deployed first with: sudo containerlab deploy -t multitenant.clab.yml"
    echo "After containerlab is deployed, run this script again."
    exit 1
fi

# Check if VM already exists
if virsh dominfo "$VM_NAME" &> /dev/null 2>&1; then
    echo "VM $VM_NAME already exists."
    read -p "Do you want to destroy and recreate it? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Destroying existing VM..."
        virsh destroy "$VM_NAME" 2>/dev/null || true
        virsh undefine "$VM_NAME" --remove-all-storage 2>/dev/null || true
    else
        echo "Exiting without changes."
        exit 0
    fi
fi

# Create the VM
echo "Creating VM $VM_NAME..."
virt-install \
    --name "$VM_NAME" \
    --memory 1024 \
    --vcpus 1 \
    --disk path="$SCRIPT_DIR/$VM_DISK",device=disk,bus=virtio \
    --disk path="$SCRIPT_DIR/$CIDATA_ISO",device=cdrom \
    --os-variant fedora41 \
    --network bridge=virbr0,model=virtio \
    --network bridge="$BRIDGE_NAME",model=virtio \
    --graphics none \
    --console pty,target_type=serial \
    --noautoconsole \
    --import

echo ""
echo "=== VM Creation Complete ==="
echo "VM Name: $VM_NAME"
echo "eth0: Connected to virbr0 (management, DHCP)"
echo "eth1: Connected to $BRIDGE_NAME (10.1.0.1/31)"
echo ""
echo "To access the VM:"
echo "  virsh console $VM_NAME"
echo "  Login: fedora / Password: fedora"
echo ""
echo "To check VM status:"
echo "  virsh list --all"
echo "  virsh domiflist $VM_NAME"
echo ""
echo "To destroy the VM:"
echo "  virsh destroy $VM_NAME"
echo "  virsh undefine $VM_NAME --remove-all-storage"
