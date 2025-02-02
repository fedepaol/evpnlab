#!/bin/bash

run_and_echo() {
    clear
    local comment="$1"
    shift

    local cmd="$*"

    echo -e "\n$comment\n\n"
    echo -e "Executing: $cmd\n"

    eval "$cmd"
    read

    echo ""
}


run_and_echo "kind cluster with metallb installed" kubectl get pods -A
run_and_echo "the frr instance is running inside the node (inside the node)" "docker exec k0-control-plane docker ps"
run_and_echo "there is one veth leg on the node to talk to frr" "docker exec k0-control-plane ip a show | grep frr"
run_and_echo "metallb is configured to peer with the local frr (inside the node)" kubectl get bgppeers -A -o yaml
run_and_echo "inside the frr instance in the node we have the interfaces required for vxlan.\nWe also have the other leg of the veth" "docker exec k0-control-plane docker exec frr ip l show"
run_and_echo "the frr instance is peered with metallb" "docker exec k0-control-plane docker exec frr vtysh -c \"show bgp vrf red summary\""
run_and_echo "no prefixes from metallb" "docker exec k0-control-plane docker exec frr vtysh -c \"show bgp vrf red ipv4\""
run_and_echo "loadbalancer service to advertise" kubectl get svc
run_and_echo "tell metallb to advertise via BGP" kubectl apply -f kind/metallb/advertise.yaml
run_and_echo "wait 4 seconds" "sleep 4s"
run_and_echo "loadbalancer service to advertise" kubectl get svc
run_and_echo "prefixes from metallb" "docker exec k0-control-plane docker exec frr vtysh -c \"show bgp vrf red ipv4\""
run_and_echo "type 5 routes" "docker exec k0-control-plane docker exec frr vtysh -c \"show bgp l2vpn evpn\""
run_and_echo "type 5 routes on leaf1" "docker exec clab-kind-leaf1 vtysh -c \"show bgp l2vpn evpn\""
run_and_echo "routes on leaf1" "docker exec clab-kind-leaf1 ip r show vrf red"
run_and_echo "hitting the service" "docker exec clab-kind-HOST1 curl 192.170.8.0"


clear
echo -e "Let's repeat while tcpdumping inside leaf1.\n\n"
curl_cmd="docker exec clab-kind-HOST1 curl 192.170.8.0"
tcpdump_cmd="docker exec k0-control-plane docker exec frr timeout 6s tcpdump -i any -nn \"port 80 or udp\""

echo -e "$tcpdump_cmd\n"
echo -e "$curl_cmd\n"

{ eval "$tcpdump_cmd" > >(cat > output1) & } ; { sleep 3s && eval "$curl_cmd" > >(cat > output2) & } ; wait
echo ""
cat output2
echo ""
cat output1
