# Topology

The idea of this lab is to have a spine - leaves topology where the two hosts are connected to two different leaves
via a L3 connection.


```raw


            ┌─────────┐
            │         │
            │  64612  │
            │         │
            └────┬────┘
                 │
                 │
         ┌───────┴────────┐
         │                │
    ┌────┴────┐      ┌────┴────┐
    │         │      │         │
    │  64512  │      │  64512  ├───────┐
    │         │      │         │       │
    └────┬────┘      └────┬────┘       │
         │                │            │        L2
    ┌────┴────┐     ┌─────┴────┐  ┌────┴─────┐
    │         │     │          │  │          │
    │  Host1  │     │   Host2  │  │   Host2  │
    │         │     │          │  │          │
    └─────────┘     └──────────┘  └──────────┘

192.168.10.2/24    192.168.10.3/24   192.168.10.4/24
```

We want to connect the two hosts via a VXLan tunnel using L2Evpn routes.

```raw

    ┌─────────┐           ┌─────────┐
    │         │   VXLan   │         │
    │  6451┌──┼───────────┼─┐64512  ├───────┐
    │      │  │           │ │       │       │
    └────┬─┴──┘           └─┴──┬────┘       │
         │                     │            │        L2
    ┌────┴────┐          ┌─────┴────┐  ┌────┴─────┐
    │         │          │          │  │          │
    │  Host1  │          │   Host2  │  │   Host2  │
    │         │          │          │  │          │
    └─────────┘          └──────────┘  └──────────┘

192.168.10.2/24         192.168.10.3/24   192.168.10.4/24

```

## How to start

The lab leverages [containerlab](https://containerlab.dev/). The [clab file](./l2.clab.yaml) contains the definition
of the FRR containers and of the two "host" containers, plus how they are connected together.

A convenience [setup.sh](./setup.sh) script is provided, to start the lab and execute the various setup commands inside the containers.


## The configuration

Each subfolder contains the frr configuration file related to the corresponding container, plus a setup.sh script used to assign IPs and
to create the VXLan and what FRR needs to make EVPN work.

For example, in the [leaf1 setup configuration file](./leaf1/setup.sh) we:

- assign the VTEP IP address to the loopback interface
- Assign IPs to the veth connecting the leaf to the spine
- Create a linux VRF corresponding to the L3 VRF
- Create all the machinery to make the EVPN / VXLan tunnel work, including a linux bridge and a VXLan interface
- Enslave the veth leg connected to the HOST to the bridge connected to the vxlan interface


## Validating

Pinging HOST2 from HOST1 should work:

```
docker exec -it clab-evpnl2-HOST1 /bin/bash -c "ping -c 1 192.168.10.4"
PING 192.168.10.4 (192.168.10.4) 56(84) bytes of data.
64 bytes from 192.168.10.4: icmp_seq=1 ttl=64 time=0.115 ms

--- 192.168.10.4 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.115/0.115/0.115/0.000 ms
```

It works! Also, let's make sure it's working through a vxlan tunnel:

```raw
sudo ip netns exec clab-evpnl2-leaf1 tcpdump -nn -i eth1
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), snapshot length 262144 bytes
11:06:19.878187 IP 100.64.0.1.53099 > 100.65.0.2.4789: VXLAN, flags [I] (0x08), vni 110
IP 192.168.10.2 > 192.168.10.4: ICMP echo request, id 21, seq 1, length 64
11:06:19.878249 IP 100.65.0.2.53099 > 100.64.0.1.4789: VXLAN, flags [I] (0x08), vni 110
IP 192.168.10.4 > 192.168.10.2: ICMP echo reply, id 21, seq 1, length 64
```
