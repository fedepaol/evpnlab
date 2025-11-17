# SERVER1 VM Setup

This folder contains everything needed to create a Fedora VM that replaces the SERVER1 container in the containerlab topology.

## Files

- `setup.sh` - Main script to download Fedora image and create the VM
- `user-data` - Cloud-init configuration for network setup
- `meta-data` - Cloud-init metadata

## Prerequisites

- libvirt and KVM installed
- virt-install command available
- genisoimage or mkisofs installed
- Containerlab topology deployed first

## Network Configuration

The VM will have two network interfaces:
- **ens2**: Connected to virbr0 (default libvirt bridge) - Management access with static IP: 192.168.122.100/24
- **ens3**: Connected to SERVER1 (containerlab bridge) - IP: 10.1.0.1/31, Gateway: 10.1.0.0

## Usage

### 1. Deploy containerlab topology first

```bash
cd /home/fpaoline/devel/evpnlab/09_clab_multitenant
sudo containerlab deploy -t multitenant.clab.yml
```

This creates the bridge `SERVER1` that the VM will connect to.

### 2. Create the VM

```bash
cd SERVER1_VM
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
sudo virsh console server1

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
sudo virsh domiflist server1

# Start VM
sudo virsh start server1

# Stop VM
sudo virsh shutdown server1

# Force stop
sudo virsh destroy server1

# Delete VM completely
sudo virsh destroy server1
sudo virsh undefine server1 --remove-all-storage
```

## Testing Connectivity

Once the VM is running, you can test connectivity to leaf1:

```bash
# From inside the VM
ping 10.1.0.0  # Should reach leaf1
```

## Troubleshooting

If the bridge doesn't exist:
- Make sure containerlab is deployed first
- Check bridge name: `sudo ip link show | grep SERVER1`
- The bridge is created by the setup.sh script before containerlab deployment

If cloud-init doesn't work:
- Check cloud-init logs in the VM: `sudo cat /var/log/cloud-init.log`
- Verify network config: `ip addr show`
