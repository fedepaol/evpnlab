#!/bin/bash

ip addr add dev eth1 192.168.11.3/24

systemctl start docker
docker run --name frr --privileged -v /frr:/etc/frr -d quay.io/frrouting/frr:9.0.0

NAMESPACE=$(docker inspect -f '{{.NetworkSettings.SandboxKey}}' frr)

ip link add frr0 type veth peer name frr1
ip link set frr0 up
ip link set dev eth1 netns $NAMESPACE
ip link set frr1 netns $NAMESPACE

sleep 2s

ip addr add dev frr0 192.169.10.0/24

docker exec frr /etc/frr/setup.sh
