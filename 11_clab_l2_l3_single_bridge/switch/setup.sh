#!/bin/bash
set -euo pipefail

sleep 3
ip link add br-host type bridge vlan_filtering 1 vlan_default_pvid 0
ip link set br-host up

# eth1 is the shared tagged trunk to leaf1.
ip link set eth1 master br-host
bridge vlan add dev eth1 vid 10
bridge vlan add dev eth1 vid 20

# Each workload-facing port accepts only its assigned VLAN.
ip link set eth2 master br-host
bridge vlan add dev eth2 vid 10 pvid untagged
ip link set eth3 master br-host
bridge vlan add dev eth3 vid 20 pvid untagged
sleep infinity
