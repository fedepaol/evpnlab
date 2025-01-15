#!/bin/bash
#
set -x


image="kindwithdocker:v1.29.2"

if [ -z "$(docker images -q $image)" ]; then
	pushd kind
	docker build . -t $image
	popd
fi


sudo clab deploy --reconfigure --topo kind.clab.yml

docker image pull quay.io/metallb/frr-k8s:main
docker image pull quay.io/frrouting/frr:10.2.0
docker image pull gcr.io/kubebuilder/kube-rbac-proxy:v0.13.1
kind load docker-image quay.io/frrouting/frr:10.2.0 --name k0
kind load docker-image gcr.io/kubebuilder/kube-rbac-proxy:v0.13.1 --name k0
kind load docker-image quay.io/metallb/frr-k8s:main --name k0

docker cp kind/setup.sh k0-control-plane:/setup.sh
docker cp kind/frr k0-control-plane:/frr
docker exec k0-control-plane /setup.sh
docker exec clab-kind-leaf2 /setup.sh
docker exec clab-kind-leaf1 /setup.sh
docker exec clab-kind-spine /setup.sh
docker exec clab-kind-HOST1 /setup.sh

kind/frr-k8s/setup.sh
