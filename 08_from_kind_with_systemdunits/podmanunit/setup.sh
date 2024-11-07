#!/bin/bash
set -x

docker cp ./start_podman.sh k0-control-plane:/root/start_podman.sh
docker cp frr k0-control-plane:/root/frr
docker cp controller k0-control-plane:/root/controller
docker exec k0-control-plane /root/start_podman.sh

