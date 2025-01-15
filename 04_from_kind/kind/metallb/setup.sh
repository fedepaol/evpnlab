#!/bin/bash

kind get kubeconfig --name k0 > kubeconfig
export KUBECONFIG=./kubeconfig

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/refs/heads/main/config/manifests/metallb-frr.yaml

sleep 2s
kubectl -n metallb-system wait --for=condition=Ready --all pods --timeout 300s

start=$(date +%s)

while true; do
    kubectl apply -f kind/metallb/metallb-config.yaml && break
    now=$(date +%s)
    elapsed=$((now - start))
    if [ $elapsed -ge 60 ]; then
        echo "Timeout reached"
        break
    fi
    sleep 1
done
