#!/bin/bash
set -x

POD_ID=$(crictl -r /var/run/containerd/containerd.sock pods  --name=frr --namespace=frrtest -q --no-trunc)
NSPATH=$(crictl -r /var/run/containerd/containerd.sock inspectp ${POD_ID} | jq -r '.info.runtimeSpec.linux.namespaces[] |select(.type=="network") | .path')
NETNS=$(basename $NSPATH)

ip link add frr0 type veth peer name frr1
ip link set frr0 up
ip link set dev eth1 netns $NETNS
ip link set frr1 netns $NETNS

sleep 2s

ip addr add dev frr0 192.169.10.0/24


