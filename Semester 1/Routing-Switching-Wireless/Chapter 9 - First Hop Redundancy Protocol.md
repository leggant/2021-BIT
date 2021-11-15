# FHRP - First Hop Redundancy Protocol

If a router or router interface (that serves as a default gateway) fails, the hosts configured with that default gateway are isolated from outside networks. A mechanism is needed to provide alternate default gateways in switched networks where two or more routers are connected to the same VLANs. That mechanism is provided by first hop redundancy protocols (FHRPs). End devices are typically configured with a single IPv4 address for a default gateway. This address does not change when the network topology changes. If that default gateway IPv4 address cannot be reached, the local device is unable to send packets off the local network segment, effectively disconnecting it from other networks. Even if a redundant router exists that could serve as a default gateway for that segment, there is no dynamic method by which these devices can determine the address of a new default gateway.

*Note: IPv6 devices receive their default gateway address dynamically from the ICMPv6 Router Advertisement. However, IPv6 devices benefit with a faster failover to the new default gateway when using FHRP.*

## Router Redundancy

One way to prevent a single point of failure at the default gateway is to implement a virtual router. To implement this type of router redundancy, multiple routers are configured to work together to present the illusion of a single router to the hosts on the LAN, as shown in the figure. By sharing an IP address and a MAC address, two or more routers can act as a single virtual router.

The IPv4 address of the virtual router is configured as the default gateway for the workstations on a specific IPv4 segment. When frames are sent from host devices to the default gateway, the hosts use ARP to resolve the MAC address that is associated with the IPv4 address of the default gateway. The ARP resolution returns the MAC address of the virtual router. Frames that are sent to the MAC address of the virtual router can then be physically processed by the currently active router within the virtual router group. A protocol is used to identify two or more routers as the devices that are responsible for processing frames that are sent to the MAC or IP address of a single virtual router. Host devices send traffic to the address of the virtual router. The physical router that forwards this traffic is transparent to the host devices.

A redundancy protocol provides the mechanism for determining which router should take the active role in forwarding traffic. It also determines when the forwarding role must be taken over by a standby router. The transition from one forwarding router to another is transparent to the end devices.

The ability of a network to dynamically recover from the failure of a device acting as a default gateway is known as first-hop redundancy.

## Steps for Router Failover

When the active router fails, the redundancy protocol transitions the standby router to the new active router role, as shown in the figure. These are the steps that take place when the active router fails:

1. The standby router stops seeing Hello messages from the forwarding router.
2. The standby router assumes the role of the forwarding router.
3. Because the new forwarding router assumes both the IPv4 and MAC addresses of the virtual router, the host devices see no disruption in service.

## FHRP Options

| FHRP Options                                          |      | Description                                                  |
| :---------------------------------------------------- | ---- | :----------------------------------------------------------- |
| Hot Standby Router Protocol (HSRP)                    |      | HRSP is a Cisco-proprietary FHRP that is designed to allow for transparent failover of a first-hop IPv4 device. HSRP provides high network availability by providing first-hop routing redundancy for IPv4 hosts on networks configured with an IPv4 default gateway address. HSRP is used in a group of routers for selecting an active device and a standby device. In a group of device interfaces, the active device is the device that is used for routing packets; the standby device is the device that takes over when the active device fails, or when pre-set conditions are met. The function of the HSRP standby router is to monitor the operational status of the HSRP group and to quickly assume packet-forwarding responsibility if the active router fails. |
| HSRP for IPv6                                         |      | This is a Cisco-proprietary FHRP that provides the same functionality of HSRP, but in an IPv6 environment. An HSRP IPv6 group has a virtual MAC address derived from the HSRP group number and a virtual IPv6 link-local address derived from the HSRP virtual MAC address. Periodic router advertisements (RAs) are sent for the HSRP virtual IPv6 link-local address when the HSRP group is active. When the group becomes inactive, these RAs stop after a final RA is sent. |
| Virtual Router Redundancy Protocol version 2 (VRRPv2) |      | This is a non-proprietary election protocol that dynamically assigns responsibility for one or more virtual routers to the VRRP routers on an IPv4 LAN. This allows several routers on a multiaccess link to use the same virtual IPv4 address. A VRRP router is configured to run the VRRP protocol in conjunction with one or more other routers attached to a LAN. In a VRRP configuration, one router is elected as the virtual router master, with the other routers acting as backups, in case the virtual router master fails. |
| VRRPv3                                                |      | This provides the capability to support IPv4 and IPv6 addresses. VRRPv3 works in multi-vendor environments and is more scalable than VRRPv2. |
| Gateway Load Balancing Protocol (GLBP)                |      | This is a Cisco-proprietary FHRP that protects data traffic from a failed router or circuit, like HSRP and VRRP, while also allowing load balancing (also called load sharing) between a group of redundant routers. |
| GLBP for IPv6                                         |      | This is a Cisco-proprietary FHRP that provides the same functionality of GLBP, but in an IPv6 environment. GLBP for IPv6 provides automatic router backup for IPv6 hosts configured with a single default gateway on a LAN. Multiple first-hop routers on the LAN combine to offer a single virtual first-hop IPv6 router while sharing the IPv6 packet forwarding load. |
| ICMP Router Discovery Protocol (IRDP)                 |      | Specified in RFC 1256, IRDP is a legacy FHRP solution. IRDP allows IPv4 hosts to locate routers that provide IPv4 connectivity to other (nonlocal) IP networks. |

## HSRP Overview

Cisco provides HSRP and HSRP for IPv6 as a way to avoid losing outside network access if your default router fails. HSRP is a Cisco-proprietary FHRP that is designed to allow for transparent failover of a first-hop IP device.

HSRP ensures high network availability by providing first-hop routing redundancy for IP hosts on networks configured with an IP default gateway address. HSRP is used in a group of routers for selecting an active device and a standby device. In a group of device interfaces, the active device is the device that is used for routing packets; the standby device is the device that takes over when the active device fails, or when pre-set conditions are met. The function of the HSRP standby router is to monitor the operational status of the HSRP group and to quickly assume packet-forwarding responsibility if the active router fails.

## HSRP Priority and Preemption

The role of the active and standby routers is determined during the HSRP election process. By default, the router with the numerically highest IPv4 address is elected as the active router. However, it is always better to control how your network will operate under normal conditions rather than leaving it to chance.

**HSRP Priority**

HSRP priority can be used to determine the active router. The router with the highest HSRP priority will become the active router. By default, the HSRP priority is 100. If the priorities are equal, the router with the numerically highest IPv4 address is elected as the active router.

To configure a router to be the active router, use the **standby priority** interface command. The range of the HSRP priority is 0 to 255.

**HSRP Preemption**

By default, after a router becomes the active router, it will remain the active router even if another router comes online with a higher HSRP priority.

To force a new HSRP election process to take place when a higher priority router comes online, preemption must be enabled using the **standby preempt** interface command. Preemption is the ability of an HSRP router to trigger the re-election process. With preemption enabled, a router that comes online with a higher HSRP priority will assume the role of the active router.

Preemption only allows a router to become the active router if it has a higher priority. A router enabled for preemption, with equal priority but a higher IPv4 address will not preempt an active router. Refer to the topology in the figure.

## HSRP States and Timers

A router can either be the active HSRP router responsible for forwarding traffic for the segment, or it can be a passive HSRP router on standby, ready to assume the active role if the active router fails. When an interface is configured with HSRP or is first activated with an existing HSRP configuration, the router sends and receives HSRP hello packets to begin the process of determining which state it will assume in the HSRP group.

The table summarizes the HSRP states.

| HSRP State | Description                                                  |
| :--------- | :----------------------------------------------------------- |
| Initial    | This state is entered through a configuration change or when an interface first becomes available. |
| Learn      | The router has not determined the virtual IP address and has not yet seen a hello message from the active router. In this state, the router waits to hear from the active router. |
| Listen     | The router knows the virtual IP address, but the router is neither the active router nor the standby router. It listens for hello messages from those routers. |
| Speak      | The router sends periodic hello messages and actively participates in the election of the active and/or standby router. |
| Standby    | The router is a candidate to become the next active router and sends periodic hello messages. |
| Active     | The router won the election.                                 |

The active and standby HSRP routers send hello packets to the HSRP group multicast address every 3 seconds by default. The standby router will become active if it does not receive a hello message from the active router after 10 seconds. You can lower these timer settings to speed up the failover or preemption. However, to avoid increased CPU usage and unnecessary standby state changes, do not set the hello timer below 1 second or the hold timer below 4 seconds.

**First Hop Redundancy Protocols**

If a router or router interface that serves as a default gateway fails, the hosts configured with that default gateway are isolated from outside networks. FHRP provides alternate default gateways in switched networks where two or more routers are connected to the same VLANs. One way to prevent a single point of failure at the default gateway, is to implement a virtual router. With a virtual router, multiple routers are configured to work together to present the illusion of a single router to the hosts on the LAN. When the active router fails, the redundancy protocol transitions the standby router to the new active router role. These are the steps that take place when the active router fails:

1. The standby router stops seeing Hello messages from the forwarding router.
2. The standby router assumes the role of the forwarding router.
3. Because the new forwarding router assumes both the IPv4 and MAC addresses of the virtual router, the host devices see no disruption in service.

The FHRP used in a production environment largely depends on the equipment and needs of the network. These are the options available for FHRPs:

- HSRP and HSRP for IPv6
- VRRPv2 and VRRPv3
- GLBP and GLBP for IPv6
- IRDP

**HSRP**

HSRP is a Cisco-proprietary FHRP designed to allow for transparent failover of a first-hop IP device. HSRP is used in a group of routers for selecting an active device and a standby device. In a group of device interfaces, the active device is the device that is used for routing packets; the standby device is the device that takes over when the active device fails, or when pre-set conditions are met. The function of the HSRP standby router is to monitor the operational status of the HSRP group and to quickly assume packet-forwarding responsibility if the active router fails. The router with the highest HSRP priority will become the active router. Pre-emption is the ability of an HSRP router to trigger the re-election process. With pre-emption enabled, a router that comes online with a higher HSRP priority will assume the role of the active router. HSRP states include initial, learn, listen, speak, and standby.

1. **What is the purpose of HSRP?** HSRP is a first hop redundancy protocol and allows hosts to use multiple gateways through the use of a single virtual router. = Provides continuous network connectivity
2. **Which non proprietary protocol provides router redundancy for a group of routers which support IPv4 LANs?** The only non proprietary FHRP used for router redundancy listed in the options is VRRPv2. HSRP and GLBP are both Cisco proprietary FHRPs. IOS SLB is a Cisco-based solution used to load balance traffic across multiple servers. = VRRPv2
3. **A network administrator is analysing first-hop router redundancy protocols. What is a characteristic of VRRPv3?** VRRPv3 is a non-proprietary, first-hop router redundancy protocol. It provides features for both IPv4 and IPv6 addressing. HSRP and GLBP are both Cisco-proprietary protocols. GLBP provides load balancing between a group of redundant routers. = It supports IPv4 and IPv6 addressing
4. **What is a potential disadvantage when implementing HSRP as compared to GLBP?** HSRP is a first-hop redundancy protocol that can utilize a group of routers, where a single router is acting as the default gateway and all other HSRP routers will maintain a backup status. GLBP supports load balancing, where multiple active routers can share the traffic load at a single time. Both HSRP and GLBP are Cisco proprietary. HSRP provides default gateway failover when pre-set conditions are met or when the active router fails, and HSRP can support IPv6 addressing. = HSRP does not provide load balancing with multiple active routers
5. **A network engineer is configuring a LAN with a redundant first hop to make better use of the available network resources. Which protocol should the engineer implement?** Gateway Load Balancing Protocol (**GLBP**) provides load sharing between a group of redundant routers while also protecting data traffic from a failed router or circuit.
6. **When first hop redundancy protocols are used, which two items will be shared by a set of routers that are presenting the illusion of being a single router? (Choose two.)**  In order for a set of routers to present the illusion of being a single router, they must share both an IP address and MAC address. A static route, BID, or hostname does not have to be shared in this context. = MAC address and IP address
7. **In FHRP terminology, what represents a set of routers that present the illusion of a single router to hosts?** In FHRP multiple routers are configured to work together to present to hosts a single gateway router. This single gateway router is a virtual router which has a virtual IP address that is used by hosts as a default gateway. = Virtual Router
8. **A user needs to add redundancy to the routers in a company. What are the three options the user can use? (Choose three.)** Three protocols that provide default gateway redundancy include **VRRP, GLBP, and HSRP.**
9. **Which two protocols provide gateway redundancy at Layer 3?** **HSRP (Hot Standby Routing Protocol) and VRRP (Virtual Router Redundancy Protocol)** are both Layer 3 redundancy protocols. Both protocols allow multiple physical routers to act as a single virtual gateway router for hosts.
10. **A network administrator is overseeing the implementation of first hop redundancy protocols. Which two protocols are Cisco proprietary? (Choose two.)** The first hop redundancy protocols **HSRP and GLBP** are Cisco proprietary and will not function in a multivendor environment.
11. **Which statement describes a characteristic of GLBP?** GLBP provides support for IPv6. It provides one virtual IP address and multiple virtual MAC addresses, and there is no such limit of four gateways to provide load balancing.
12. **A network administrator is analysing the features that are supported by different first-hop router redundancy protocols. Which statement is a feature that is associated with GLBP?** The GLBP first-hop router redundancy protocol is Cisco proprietary and supports load balancing between a group of redundant routers. VRRPv2 and VRRPv3 are non proprietary protocols and use a virtual router master.  **GLBP Allows Load Balancing Between Routers**

