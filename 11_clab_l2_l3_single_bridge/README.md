# L2/L3 EVPN with shared and traditional L2 overlays

This lab extends [03_clab_l2_l3](../03_clab_l2_l3) with the [single bridge and VXLAN device model](https://docs.frrouting.org/en/latest/evpn.html#vlan-filtering-bridge-and-single-vxlan-device) for two L2VNIs in VRF `red`, as proposed in [OpenPERouter's VLAN-tag design](https://github.com/openperouter/openperouter/pull/783). It also includes a traditional, dedicated-bridge L2VNI in VRF `blue`:

| VRF | VNI | Type | Linux devices | Host network |
| --- | --- | --- | --- | --- |
| red | 110 | Shared L2, VLAN 10 | `br0`, `vxlan0`, `vlan10` | 192.168.10.0/24 |
| red | 111 | Shared L2, VLAN 20 | `br0`, `vxlan0`, `vlan20` | 192.168.11.0/24 |
| red | 100 | Traditional L3 | `br100`, `vni100` | Routed hosts |
| blue | 130 | Traditional L2 | `br30`, `vni130` | 192.168.20.0/24 |
| blue | 200 | Traditional L3 | `br200`, `vni200` | Routed hosts |

Both L3VNIs and the blue L2VNI use bridges with VLAN filtering disabled. The shared L2 `vxlan0` uses UDP port 4789; the traditional `vni100`, `vni130`, and `vni200` devices use UDP port 4790 on both leaves.

Each leaf's `eth2` is a tagged trunk for red VLANs 10 and 20. `switch1` and `switch2` stand in for a shared host bridge: their `eth1` carries the trunk, while `eth2` and `eth3` are access ports for LAN 1 and LAN 2. The blue L2 host connects directly to `br30` on leaf `eth4`. Red and blue L3 hosts connect directly to their VRFs on leaf `eth3` and `eth5`.

## Why two VXLAN UDP ports?

On the tested Linux 6.19.10 kernel, an `external vnifilter` VXLAN device and a traditional VXLAN device can both be created with `dstport 4789`, but bringing the second one up fails with `RTNETLINK answers: Address in use`. Reversing creation order or using different local VTEP IPs gives the same result. Two traditional devices can share 4789, as can two `external vnifilter` devices with distinct VNIs. The mixed pair comes up when the traditional device uses 4790.

The kernel shares a VXLAN UDP socket only when its [receive flags match](https://github.com/torvalds/linux/blob/v6.19/include/net/vxlan.h#L313-L322). `external vnifilter` and traditional VXLAN have different receive flags, so the [socket lookup attempts to create a second listener](https://github.com/torvalds/linux/blob/v6.19/drivers/net/vxlan/vxlan_core.c#L3394-L3422); binding it to the already used UDP port fails. The listener [binds by port and device index](https://github.com/torvalds/linux/blob/v6.19/drivers/net/vxlan/vxlan_core.c#L3314-L3337), which explains why a different local VTEP IP does not help. Any peer carrying the traditional VNIs in this lab must also use UDP port 4790.

## Start

From this directory, run `./setup.sh`. It deploys the [containerlab topology](./l2-l3.clab.yml), then configures the leaf and spine interfaces. Containerlab, Docker, and a Linux kernel with VXLAN `external` and `vnifilter` support are required. This lab uses FRR 10.7.1.

## Validate

Check that the shared device carries VNIs 110 and 111, while the traditional devices carry VNIs 100, 130, and 200:

```sh
docker exec clab-evpnl2-l3-svd-leaf1 bridge vlan tunnelshow
docker exec clab-evpnl2-l3-svd-leaf1 bridge vni show
docker exec clab-evpnl2-l3-svd-leaf1 ip -d link show br100
docker exec clab-evpnl2-l3-svd-leaf1 ip -d link show br30
docker exec clab-evpnl2-l3-svd-leaf1 ip -d link show br200
docker exec clab-evpnl2-l3-svd-leaf1 vtysh -c 'show evpn vni'
docker exec clab-evpnl2-l3-svd-leaf1 vtysh -c 'show vrf vni'
```

With the tested FRR 10.7.1 image, `show evpn vni` reports VLAN 0 for VNI 111. The kernel mapping from VLAN 20 to VNI 111 is visible in `bridge vlan tunnelshow`, and traffic on that VNI forwards successfully.

Check both L2 overlays, routing within each VRF, and both L3VNIs:

```sh
docker exec clab-evpnl2-l3-svd-HOST_LAN1_1 ping -c 3 192.168.10.3
docker exec clab-evpnl2-l3-svd-HOST_LAN1_1 ping -c 3 192.168.11.3
docker exec clab-evpnl2-l3-svd-HOST_L3_1 ping -c 3 192.170.10.2
docker exec clab-evpnl2-l3-svd-HOST_BLUE_L2_1 ping -c 3 192.168.20.3
docker exec clab-evpnl2-l3-svd-HOST_BLUE_L2_1 ping -c 3 192.172.10.2
docker exec clab-evpnl2-l3-svd-HOST_BLUE_L3_1 ping -c 3 192.172.10.2
```

The cross-leaf red and blue L3 host pings exercise L3VNIs 100 and 200 respectively. For an encapsulation check, run `tcpdump -nn -i eth1 'udp port 4789 or udp port 4790'` in a leaf while pinging a remote host.

The VRFs are isolated: a red host cannot ping `192.168.20.3`, and a blue host cannot ping `192.168.10.3`.
