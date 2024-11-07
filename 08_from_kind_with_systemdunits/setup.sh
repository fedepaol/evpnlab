#!/bin/bash
#
pushd kind
image="kindwithpodman:v1.29.2"

if [ -z "$(docker images -q $image)" ]; then
	docker build . -t $image
fi
popd


sudo clab deploy --reconfigure --topo kindsystemd.clab.yml

docker exec clab-kind-leaf1 /setup.sh
docker exec clab-kind-leaf2 /setup.sh
docker exec clab-kind-spine /setup.sh

docker image pull quay.io/metallb/frr-k8s:main
docker image pull gcr.io/kubebuilder/kube-rbac-proxy:v0.13.1
kind load docker-image gcr.io/kubebuilder/kube-rbac-proxy:v0.13.1 --name k0
kind load docker-image quay.io/metallb/frr-k8s:main --name k0


kind/frr-k8s/setup.sh
docker exec clab-kindpods-leaf2 /setup.sh
docker exec clab-kindpods-leaf1 /setup.sh
docker exec clab-kindpods-spine /setup.sh
docker exec clab-kindpods-HOST1 /setup.sh

pushd podmanunit
	./setup.sh
popd

