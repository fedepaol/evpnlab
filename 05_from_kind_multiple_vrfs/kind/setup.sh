#!/bin/bash

ip addr add dev eth1 192.168.11.3/24

systemctl start docker
docker run --name frr --privileged -v /frr:/etc/frr -d quay.io/frrouting/frr:9.0.0

NAMESPACE=$(docker inspect -f '{{.NetworkSettings.SandboxKey}}' frr)

ip link add red0 type veth peer name red1
ip link set red0 up
ip link set dev eth1 netns $NAMESPACE
ip link set red1 netns $NAMESPACE

ip link add green0 type veth peer name green1
ip link set green0 up
ip link set green1 netns $NAMESPACE

sleep 5s

ip addr add dev red0 192.169.10.0/24
ip addr add dev green0 192.169.11.0/24

docker exec frr /etc/frr/setup.sh
