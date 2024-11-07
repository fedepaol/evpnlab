
pushd kind
image="kindwithpodman:v1.29.2"

if [ -z "$(docker images -q $image)" ]; then
	docker build . -t $image
fi

kind delete cluster || true
kind create cluster --config kindconfig.yaml
popd

docker cp ./start_podman.sh kind-control-plane:/root/start_podman.sh
docker cp frr kind-control-plane:/root/frr
docker cp controller kind-control-plane:/root/controller
docker exec kind-control-plane /root/start_podman.sh
