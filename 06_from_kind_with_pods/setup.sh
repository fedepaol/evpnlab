#!/bin/bash
#

pushd frrpods/controller
docker image build . -t controller:dev
popd
pushd frrpods/frr
docker image build . -t frr:dev
popd

sudo clab deploy --reconfigure --topo kind.clab.yml

docker image pull quay.io/metallb/frr-k8s:main
docker image pull quay.io/frrouting/frr:10.2.0
docker image pull gcr.io/kubebuilder/kube-rbac-proxy:v0.13.1
kind load docker-image quay.io/frrouting/frr:10.2.0 --name k0
kind load docker-image gcr.io/kubebuilder/kube-rbac-proxy:v0.13.1 --name k0
kind load docker-image quay.io/metallb/frr-k8s:main --name k0
kind load docker-image controller:dev --name k0
kind load docker-image frr:dev --name k0

docker cp kind/setup.sh k0-control-plane:/setup.sh
docker cp kind/frr k0-control-plane:/frr
docker exec k0-control-plane /setup.sh

kind --name k0 get kubeconfig > kubeconfig
export KUBECONFIG=$(pwd)/kubeconfig
kind/frr-k8s/setup.sh

kubectl apply -f frrpods/controller/controller.yaml
kubectl apply -f frrpods/frr/frrpod.yaml

sleep 4s
docker exec clab-kindpods-leaf1 /setup.sh
docker exec clab-kindpods-leaf2 /setup.sh
docker exec clab-kindpods-spine /setup.sh
docker exec clab-kindpods-HOST1 /setup.sh


kubectl exec -n frrtest controller /tmp/setup.sh
kubectl exec -n frrtest frr /tmp/setup.sh
