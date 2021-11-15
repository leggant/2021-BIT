# Spanning Tree Protocol (STP)

A Layer 2 loop creates similar chaos in a network. It can happen very quickly and make it impossible to use the network. There are a few common ways that a Layer 2 loop can be created and propagated. Spanning Tree Protocol (STP) is designed specifically to eliminate Layer 2 loops in your network. Path redundancy provides multiple network services by eliminating the possibility of a single point of failure. When multiple paths exist between two devices on an Ethernet network, and there is no spanning tree implementation on the switches, a Layer 2 loop occurs. 

Redundancy is an important to eliminating single points of failure and preventing disruption of network services. Redundant networks require the addition of physical paths, but logical redundancy must also be part of the design. Redundant paths in a switched Ethernet network may cause both physical and logical Layer 2 loops. A loop in an Ethernet LAN can cause continued propagation of Ethernet frames until a link is disrupted and breaks the loop.

STP is a loop-prevention network protocol that allows for redundancy while creating a loop-free Layer 2 topology. IEEE 802.1D is the original IEEE MAC Bridging standard for STP.


STP creates, negotiates and manages a blocked port in the network topology, preventing a layer 2 loop. STP handles network disruption on active links. Breaks in the network will cause a blocked port to activate allowing traffic to transmit with little to no disruption. 

A Layer 2 loop can result in MAC address table instability, link saturation, and high CPU utilization on switches and end-devices, resulting in the network becoming unusable.

Unlike the Layer 3 protocols, IPv4 and IPv6, Layer 2 Ethernet does not include a mechanism to recognize and eliminate endlessly looping frames. Both IPv4 and IPv6 include a mechanism that limits the number of times a Layer 3 networking device can retransmit a packet.
 
## Layer 2 Loops

Broadcast frames, such as an ARP Request are forwarded out all of the switch ports, except the original ingress port. This ensures that all devices in a broadcast domain are able to receive the frame. If there is more than one path for the frame to be forwarded out of, an endless loop can result. When a loop occurs, the MAC address table on a switch will constantly change with the updates from the broadcast frames, which results in MAC database instability. This can cause high CPU utilization, which makes the switch unable to forward frames.

Broadcast frames are not the only type of frames that are affected by loops. Unknown unicast frames sent onto a looped network can result in duplicate frames arriving at the destination device. An unknown unicast frame is when the switch does not have the destination MAC address in its MAC address table and must forward the frame out all ports, except the ingress port.

## Broadcast Storms
A broadcast storm is an abnormally high number of broadcasts overwhelming the network during a specific amount of time. Broadcast storms can disable a network within seconds by overwhelming switches and end devices. Broadcast storms can be caused by a hardware problem such as a faulty NIC or from a Layer 2 loop in the network. A host caught in a Layer 2 loop is not accessible to other hosts on the network. Additionally, due to the constant changes in its MAC address table, the switch does not know out of which port to forward unicast frames.

# Spanning Tree Algorithm (STA)
STA creates a loop-free topology by selecting a single root bridge where all other switches determine a single least-cost path. STP prevents loops from occurring by configuring a loop-free path through the network using strategically placed "blocking-state" ports. The switches running STP are able to compensate for failures by dynamically unblocking the previously blocked ports and permitting traffic to traverse the alternate paths.

1. Ethernet LAN with redundant connections between multiple switches.
2. Select the Root Bridge. spanning tree algorithm begins by selecting a single root bridge (switch) - Each switch will determine a single, least cost path from itself to the root bridge.
3. Block Redundant Paths. Ensures that there is only one logical path between all destinations on the network by intentionally blocking redundant paths that could cause a loop. 
4. Loop-Free Topology; A blocked port has the effect of making that link a non-forwarding link between the two switches. each switch has only a single path to the root bridge.
5. Link Failure Causes Recalculation physical paths still exist to provide redundancy, but these paths are disabled to prevent the loops from occurring. If the path is ever needed to compensate for a network cable or switch failure, STP recalculates the paths and unblocks the necessary ports to allow the redundant path to become active. STP recalculations can also occur any time a new switch or new inter-switch link is added to the network. There is still only one path between every switch and the root bridge.

# STP Operations

1. Elect the root bridge.
2. Elect the root ports.
3. Elect designated ports.
4. Elect alternate (blocked) ports.