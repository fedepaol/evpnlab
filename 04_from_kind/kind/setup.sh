#!/bin/bash

ip addr add dev eth1 192.168.11.3/24

systemctl start docker
docker run --name frr --privileged -v /frr:/etc/frr -d quay.io/frrouting/frr:10.2.0

NAMESPACE=$(docker inspect -f '{{.NetworkSettings.SandboxKey}}' frr)

ip link add frrhost type veth peer name frrns
ip link set frrhost up
ip link set dev eth1 netns $NAMESPACE
ip link set frrns netns $NAMESPACE

sleep 2s

ip addr add dev frrhost 192.169.10.0/24

ip route add 192.168.10.1/32 via 192.169.10.1 # STATIC ROUTE REQUIRED TO REACH HOST1
docker exec frr /etc/frr/setup.sh
