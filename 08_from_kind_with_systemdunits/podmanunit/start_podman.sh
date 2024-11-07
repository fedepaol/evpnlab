#!/bin/bash
set -x

podman pod create --share=+pid --name=frrpod -p 7080:7080 
podman create --pod=frrpod --pidfile=/root/frr/frrpid --name=frr --cap-add=CAP_NET_BIND_SERVICE,CAP_NET_ADMIN,CAP_NET_RAW,CAP_SYS_ADMIN -v=/root/frr:/etc/frr -v=varfrr:/var/run/frr:Z -t quay.io/frrouting/frr:master /etc/frr/start.sh
podman create --pod=frrpod --name=reloader -v=/root/frr:/etc/frr -v=varfrr:/var/run/frr:Z --entrypoint=/etc/frr/reloader.sh -t quay.io/frrouting/frr:master 
podman generate systemd --new --files --name frrpod

sleep 10s #hack to wait /run/ns to appear
podman pod create --name=controllerpod
podman create --pod=controllerpod --name=controller -v=/root/frr:/etc/frr:rshared -v=/run/containerd/containerd.sock:/run/containerd/containerd.sock:rshared -v=/run/netns:/run/netns:rshared --network=host --cap-add=CAP_NET_BIND_SERVICE,CAP_NET_ADMIN,CAP_NET_RAW,CAP_SYS_ADMIN --pid=host -v=/root/controller:/etc/controller fedora:latest sleep inf

podman generate systemd --new --files --name controllerpod
cp ./*.service /etc/systemd/system

systemctl enable pod-controllerpod
systemctl enable pod-frrpod

systemctl start pod-controllerpod
systemctl start pod-frrpod


podman exec controller /etc/controller/setup.sh
