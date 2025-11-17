# STORAGE VM Setup

This folder contains everything needed to create a Fedora VM that replaces the STORAGE container in the containerlab topology.

## Files

- `setup.sh` - Main script to download Fedora image and create the VM
- `user-data` - Cloud-init configuration for user setup
- `meta-data` - Cloud-init metadata
- `network-config` - Cloud-init network configuration

## Prerequisites

- libvirt and KVM installed
- virt-install command available
- genisoimage or mkisofs installed
- Containerlab topology deployed first

## Network Configuration

The VM will have two network interfaces:
- **ens2**: Connected to virbr0 (default libvirt bridge) - Management access with static IP: 192.168.122.101/24
- **ens3**: Connected to STORAGE (containerlab bridge) - IP: 10.1.0.7/31, Gateway: 10.1.0.6

## Usage

### 1. Deploy containerlab topology first

```bash
cd /home/fpaoline/devel/evpnlab/09_clab_multitenant
sudo containerlab deploy -t multitenant.clab.yml
```

This creates the bridge `STORAGE` that the VM will connect to.

### 2. Create the VM

```bash
cd STORAGE_VM
sudo ./setup.sh
```

The script will:
- Download Fedora Cloud image (if not present)
- Create a VM disk
- Generate cloud-init ISO
- Create the VM with two NICs (ens2 on virbr0, ens3 on containerlab bridge)

### 3. Access the VM

```bash
# Console access
sudo virsh console storage

# Login credentials
Username: fedora
Password: fedora
```

Press `Ctrl+]` to exit the console.

## VM Management

```bash
# Check VM status
sudo virsh list --all

# See network interfaces
sudo virsh domiflist storage

# Start VM
sudo virsh start storage

# Stop VM
sudo virsh shutdown storage

# Force stop
sudo virsh destroy storage

# Delete VM completely
sudo virsh destroy storage
sudo virsh undefine storage --remove-all-storage
```

## Testing Connectivity

Once the VM is running, you can test connectivity to storageleaf:

```bash
# From inside the VM
ping 10.1.0.6  # Should reach storageleaf
```

## Troubleshooting

If the bridge doesn't exist:
- Make sure containerlab is deployed first
- Check bridge name: `sudo ip link show | grep STORAGE`
- The bridge is created by containerlab deployment

If cloud-init doesn't work:
- Check cloud-init logs in the VM: `sudo cat /var/log/cloud-init.log`
- Verify network config: `ip addr show`
