# EVPN Multitenancy Lab

This lab demonstrates a multitenancy EVPN/VXLan deployment with tenant isolation, shared storage access, and common internet connectivity.

![Network Topology](multitenancy.png)

## Overview

The lab implements a spine-leaf architecture with EVPN/VXLan overlay to support multiple isolated tenants while providing:

- **Tenant Isolation**: Red and blue VRFs are completely isolated from each other
- **Shared Storage**: All tenants can access a common storage service via the Storage Leaf
- **Internet Access**: Common internet connectivity through the Border Leaf

## Topology

The topology consists of:

- **Spine**: Core router providing underlay connectivity (AS 64612)
- **Leaf 1**: Access switch for Server 1 (red tenant)
- **Leaf 2**: Access switch for Server 2 (blue tenant) and Server 3 (red tenant)
- **Storage Leaf**: Provides shared storage access for Server 4
- **Border Leaf**: Gateway to the internet
- **Servers**:
  - Server 1 (red tenant) - connected to Leaf 1
  - Server 2 (blue tenant) - connected to Leaf 2
  - Server 3 (red tenant) - connected to Leaf 2
  - Server 4 (green tenant) - storage server connected to Storage Leaf
- **Internet**: External connectivity container

## VRF Design

### Red VRF
- Server 1 (Leaf 1)
- Server 3 (Leaf 2)
- Isolated from blue VRF
- Access to shared storage
- Access to internet via Border Leaf

### Blue VRF
- Server 2 (Leaf 2)
- Isolated from red VRF
- Access to shared storage
- Access to internet via Border Leaf

### Storage VRF (Green)
- Server 4 (Storage Leaf)
- Accessible from both red and blue VRFs
- Implements shared storage service

## EVPN/VXLan Implementation

The lab uses:
- **L3 EVPN**: Type 5 routes for inter-subnet routing
- **VXLan Tunnels**: Overlay network between VTEPs
- **VRF Route Leaking**: Controlled route import/export between VRFs for storage and internet access
- **BGP EVPN**: Control plane using BGP with EVPN address family

Each leaf acts as a VTEP (VXLan Tunnel Endpoint) and exchanges EVPN routes with the spine to:
- Learn remote MAC/IP bindings
- Establish VXLan tunnels
- Maintain tenant isolation through VRF separation

## How to Start

The lab leverages [containerlab](https://containerlab.dev/). The containerlab file contains the definition of the FRR containers and server containers, plus their interconnections.

A convenience script is provided to start the lab and execute the various setup commands inside the containers:

```bash
./setup.sh
```

## Configuration Structure

Each device subfolder contains:
- **frr.conf**: FRR routing configuration (BGP, EVPN)
- **setup.sh**: Interface configuration, VRF setup, VXLan tunnel creation

For example, in the leaf configurations we:
- Assign VTEP IP addresses to loopback interfaces
- Configure VRFs for tenant isolation
- Create VXLan interfaces with appropriate VNIs
- Configure BGP EVPN with route-targets for VRF isolation
- Set up route leaking for storage and internet access

## Key Features

### Tenant Isolation
Each VRF uses unique route-targets to ensure complete isolation:
- Red VRF: RT 65000:100
- Blue VRF: RT 65000:200
- Storage access via selective route import/export

### Shared Services
- Storage VRF routes are selectively imported into tenant VRFs
- Internet routes are imported from Border Leaf VRF
- Traffic remains isolated between red and blue tenants

## Verification

After starting the lab, you can verify the multitenancy isolation and shared storage access with the following tests:

### Test 1: Verify Red VRF Connectivity
Servers in the same VRF (red) should be able to communicate:

```bash
# From Server 1 (red VRF) to Server 3 (red VRF)
docker exec -it clab-evpnl3-SERVER1 ping -c 3 10.1.0.5
```

Expected result: **SUCCESS** - Ping should work between red VRF servers.

### Test 2: Verify VRF Isolation
Servers in different VRFs should NOT be able to communicate:

```bash
# From Server 1 (red VRF) to Server 2 (blue VRF)
docker exec -it clab-evpnl3-SERVER1 ping -c 3 10.1.0.3
```

Expected result: **FAILURE** - Ping should fail, demonstrating VRF isolation.

### Test 3: Verify Shared Storage Access from Red VRF
Both red VRF servers should be able to reach the shared storage:

```bash
# From Server 1 (red VRF) to Storage
docker exec -it clab-evpnl3-SERVER1 ping -c 3 10.1.0.7

# From Server 3 (red VRF) to Storage
docker exec -it clab-evpnl3-SERVER3 ping -c 3 10.1.0.7
```

Expected result: **SUCCESS** - Both pings should work, demonstrating shared storage access.

### Test 4: Verify Shared Storage Access from Blue VRF
The blue VRF server should also be able to reach the shared storage:

```bash
# From Server 2 (blue VRF) to Storage
docker exec -it clab-evpnl3-SERVER2 ping -c 3 10.1.0.7
```

Expected result: **SUCCESS** - Ping should work, confirming storage is accessible from blue VRF too.

### Summary
These tests confirm:
- ✓ Servers within the same VRF can communicate
- ✓ Servers in different VRFs are isolated from each other
- ✓ All VRFs can access the shared storage service

