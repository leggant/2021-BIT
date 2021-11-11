# Chapter 5 - Etherchannels

EtherChannel is a link aggregation technology that groups multiple physical Ethernet links together into one single logical link. It is used to provide fault-tolerance, load sharing, increased bandwidth, and redundancy between switches, routers, and servers.
EtherChannel allows up to eight redundant links to be bundled together into one logical link.
EtherChannel technology makes it possible to combine the number of physical links between the switches to increase the overall speed of switch-to-switch communication. grouping several Fast Ethernet or Gigabit Ethernet ports into one logical channel. When an EtherChannel is configured, the resulting virtual interface is called a port channel. The physical interfaces are bundled together into a port channel interface.

## Advantages of EtherChannel
EtherChannel technology has many advantages, including the following:

Most configuration tasks can be done on the EtherChannel interface instead of on each individual port, ensuring configuration consistency throughout the links.
EtherChannel relies on existing switch ports. There is no need to upgrade the link to a faster and more expensive connection to have more bandwidth.
Load balancing takes place between links that are part of the same EtherChannel. Depending on the hardware platform, one or more load-balancing methods can be implemented. These methods include source MAC and destination MAC load balancing, or source IP and destination IP load balancing, across the physical links.
EtherChannel creates an aggregation that is seen as one logical link. When several EtherChannel bundles exist between two switches, STP may block one of the bundles to prevent switching loops. When STP blocks one of the redundant links, it blocks the entire EtherChannel. This blocks all the ports belonging to that EtherChannel link. Where there is only one EtherChannel link, all physical links in the EtherChannel are active because STP sees only one (logical) link.
EtherChannel provides redundancy because the overall link is seen as one logical connection. Additionally, the loss of one physical link within the channel does not create a change in the topology. Therefore, a spanning tree recalculation is not required. Assuming at least one physical link is present; the EtherChannel remains functional, even if its overall throughput decreases because of a lost link within the EtherChannel.

## Restrictions

EtherChannel has certain implementation restrictions, including the following:

1. Interface types cannot be mixed. For example, Fast Ethernet and Gigabit Ethernet cannot be mixed within a single EtherChannel.
2. Currently each EtherChannel can consist of up to eight compatibly-configured Ethernet ports. EtherChannel provides full-duplex bandwidth up to 800 Mbps (Fast EtherChannel) or 8 Gbps (Gigabit EtherChannel) between one switch and another switch or host.
3. The Cisco Catalyst 2960 Layer 2 switch currently supports up to six EtherChannels. However, as new IOSs are developed and platforms change, some cards and platforms may support increased numbers of ports within an EtherChannel link, as well as support an increased number of Gigabit EtherChannels.
4. The individual EtherChannel group member port configuration must be consistent on both devices. If the physical ports of one side are configured as trunks, the physical ports of the other side must also be configured as trunks within the same native VLAN. Additionally, all ports in each EtherChannel link must be configured as Layer 2 ports.
5. Each EtherChannel has a logical port channel interface, as shown in the figure. A configuration applied to the port channel interface affects all physical interfaces that are assigned to that interface.

# AutoNegotiation Protocols

EtherChannels can be formed through negotiation using one of two protocols, Port Aggregation Protocol (PAgP) or Link Aggregation Control Protocol (LACP). These protocols allow ports with similar characteristics to form a channel through dynamic negotiation with adjoining switches.

Note: It is also possible to configure a static or unconditional EtherChannel without PAgP or LACP.

## PAgP Operation

PAgP helps create the EtherChannel link by detecting the configuration of each side and ensuring that links are compatible so that the EtherChannel link can be enabled when needed. The modes for PAgP as follows:

- On - This mode forces the interface to channel without PAgP. Interfaces configured in the on mode do not exchange PAgP packets.
- PAgP desirable - This PAgP mode places an interface in an active negotiating state in which the interface initiates negotiations with other interfaces by sending PAgP packets.
- PAgP auto - This PAgP mode places an interface in a passive negotiating state in which the interface responds to the PAgP packets that it receives but does not initiate PAgP negotiation.

The modes must be compatible on each side. If one side is configured to be in auto mode, it is placed in a passive state, waiting for the other side to initiate the EtherChannel negotiation. If the other side is also set to auto, the negotiation never starts and the EtherChannel does not form. If all modes are disabled by using the no command, or if no mode is configured, then the EtherChannel is disabled.

The on mode manually places the interface in an EtherChannel, without any negotiation. It works only if the other side is also set to on. If the other side is set to negotiate parameters through PAgP, no EtherChannel forms, because the side that is set to on mode does not negotiate.

No negotiation between the two switches means there is no checking to make sure that all the links in the EtherChannel are terminating on the other side, or that there is PAgP compatibility on the other switch.

### PAgP Modes
|S1|	S2|	Channel Establishment|
|--|------|----------------------|
|On|	On|	Yes|
|On|	Desirable/Auto	|No|
|Desirable|	Desirable|	Yes|
|Desirable	|Auto|	Yes|
|Auto|	Desirable|	Yes|
|Auto	|Auto|	No|

## LACP Operation

LACP allows a switch to negotiate an automatic bundle by sending LACP packets to the other switch. It performs a function similar to PAgP with Cisco EtherChannel. Because LACP is an IEEE standard, it can be used to facilitate EtherChannels in multivendor environments. On Cisco devices, both protocols are supported.

LACP was originally defined as IEEE 802.3ad. However, LACP is now defined in the newer IEEE 802.1AX standard for local and metropolitan area networks.

LACP provides the same negotiation benefits as PAgP. LACP helps create the EtherChannel link by detecting the configuration of each side and making sure that they are compatible so that the EtherChannel link can be enabled when needed. The modes for LACP are as follows:

- On - This mode forces the interface to channel without LACP. Interfaces configured in the on mode do not exchange LACP packets.
- LACP active - This LACP mode places a port in an active negotiating state. In this state, the port initiates negotiations with other ports by sending LACP packets.
- LACP passive - This LACP mode places a port in a passive negotiating state. In this state, the port responds to the LACP packets that it receives but does not initiate LACP packet negotiation.

Just as with PAgP, modes must be compatible on both sides for the EtherChannel link to form. The on mode is repeated, because it creates the EtherChannel configuration unconditionally, without PAgP or LACP dynamic negotiation.

LACP allows for eight active links, and also eight standby links. A standby link will become active should one of the current active links fail.

### Combination of LACP mode

|S1|	S2|	Channel Establishment|
|--|-----|----|
|On|	On|	Yes|
|On|	Active/Passive|	No|
|Active|	Active|	Yes|
|Active|	Passive|	Yes|
|Passive|	Active|	Yes|
|Passive|	Passive	|No|

# EtherChannel Configuration

- EtherChannel support - All Ethernet interfaces must support EtherChannel with no requirement that interfaces be physically contiguous.
- Speed and duplex - Configure all interfaces in an EtherChannel to operate at the same speed and in the same duplex mode.
- VLAN match - All interfaces in the EtherChannel bundle must be assigned to the same VLAN or be configured as a trunk (shown in the figure).
- Range of VLANs - An EtherChannel supports the same allowed range of VLANs on all the interfaces in a trunking EtherChannel. If the allowed range of VLANs is not the same, the interfaces do not form an EtherChannel, even when they are set to auto or desirable mode.

## LACP Config Example

**Step 1.** Specify the interfaces that compose the EtherChannel group using the interface range interface global configuration mode command. The range keyword allows you to select several interfaces and configure them all together.

**Step 2.** Create the port channel interface with the channel-group identifier mode active command in interface range configuration mode. The identifier specifies a channel group number. The mode active keywords identify this as an LACP EtherChannel configuration.

**Step 3.** To change Layer 2 settings on the port channel interface, enter port channel interface configuration mode using the interface port-channel command, followed by the interface identifier. In the example, S1 is configured with an LACP EtherChannel. The port channel is configured as a trunk interface with the allowed VLANs specified.

```
S1(config)# interface range FastEthernet 0/1 - 2
S1(config-if-range)# channel-group 1 mode active
Creating a port-channel interface Port-channel 1
S1(config-if-range)# exit
S1(config)# interface port-channel 1
S1(config)# switchport mode trunk
S1(config)# switchport trunk allowed vlan 1,2,20
```

# Configure Etherchannel - Packet Tracer Example

```
S1# show interfaces | include Ethernet
S1# show interface status
S1# show interfaces trunk
```
Configure all ports that are required for the EtherChannels as static trunk ports.

Note: If the ports are configured with DTP dynamic auto mode, and you do not set the mode of the ports to trunk, the links do not form trunks and remain access ports. The default mode on a 2960 switch is for DTP to be enabled and set to dynamic auto. DTP can be disabled on interfaces with the `switchport nonegotiate` command.

```
S1# show interfaces trunk
Port Mode Encapsulation Status Native vlan
F0/21 on 802.1q trunking 1
F0/22 on 802.1q trunking 1
G0/1 on 802.1q trunking 1
G0/2 on 802.1q trunking 1
```
```
S1(config)# interface range f0/21 – 22
S1(config-if-range)# shutdown
S1(config-if-range)# channel-group 1 mode desirable
S1(config-if-range)# no shutdown

S3(config)# interface range f0/21 - 22
S3(config-if-range)# shutdown
S3(config-if-range)# channel-group 1 mode desirable
S3(config-if-range)# no shutdown
```

```
S1(config)# interface port-channel 1
S1(config-if)# switchport mode trunk

S3(config)# interface port-channel 1
S3(config-if)# switchport mode trunk

S1# show etherchannel summary
```
The `show interfaces trunk` and `show spanning-tree` commands should show the port channel as one logical link.

# Troubleshooting

1. `show interfaces port-channel #enternumber`
2. `show etherchannel summary` command to display one line of information per port channel. In the output, the switch has one EtherChannel configured.
3. `show etherchannel port-channel` command to display information about a specific port channel interface.
4. physical interface member of an EtherChannel bundle, the `show interfaces f0/1 etherchannel` command can provide information about the role of the interface in the EtherChannel, as shown in the output.
5. `show run | begin interface port-channel`
6. `no interface port-channel #1(number)` - to remove a port channel before correcting it.

All interfaces within an EtherChannel must have the same configuration of speed and duplex mode, native and allowed VLANs on trunks, and access VLAN on access ports. Ensuring these configurations will significantly reduce network problems related to EtherChannel. Common EtherChannel issues include the following:

Assigned ports in the EtherChannel are not part of the same VLAN, or not configured as trunks. Ports with different native VLANs cannot form an EtherChannel.
Trunking was configured on some of the ports that make up the EtherChannel, but not all of them. It is not recommended that you configure trunking mode on individual ports that make up the EtherChannel. When configuring a trunk on an EtherChannel, verify the trunking mode on the EtherChannel.

If the allowed range of VLANs is not the same, the ports do not form an EtherChannel even when PAgP is set to the auto or desirable mode.
The dynamic negotiation options for PAgP and LACP are not compatibly configured on both ends of the EtherChannel.

Note: It is easy to confuse PAgP or LACP with DTP, because they are all protocols used to automate behavior on trunk links. PAgP and LACP are used for link aggregation (EtherChannel). DTP is used for automating the creation of trunk links. When an EtherChannel trunk is configured, typically EtherChannel (PAgP or LACP) is configured first and then DTP.

Module Quiz - Etherchannel


Topic 6.1.0 - An EtherChannel link will be formed using LACP when both switches are in on mode or in active mode, or when one of them is in passive mode and the other is in active mode.

Topic 6.1.0 - The command channel-group mode active enables LACP unconditionally, and the command channel-group mode passive enables LACP only if the port receives an LACP packet from another device. The command channel-group mode desirable enables PAgP unconditionally, and the command channel-group mode auto enables PAgP only if the port receives a PAgP packet from another device.

Topic 6.1.0 - There are some EtherChannel modes that can be different and an EtherChannel will form, such as auto/desirable and active/passive. A port that is currently in the spanning tree blocking mode or has been configured for PortFast can still be used to form an EtherChannel.

Topic 6.1.0 - Most configuration tasks can be done on the EtherChannel interface, rather than on individual ports. Existing ports can be used, eliminating the need to upgrade ports to faster speeds. Spanning Tree Protocol runs on EtherChannel links in the same manner as it does on regular links, but it does not recalculate when an individual link within the channel goes down. EtherChannel also supports load balancing.

Topic 6.1.0 - An EtherChannel is seen as one logical connection. The loss of one physical link within the channel does not create a change in the topology and therefore a spanning tree recalculation is not required. When one of the member ports in the EtherChannel fails, the EtherChannel link remains functional, although its overall throughput decreases because of a lost link within the EtherChannel.

Topic 6.1.0 - When EtherChannel is being configured, the first step is to specify what physical ports will be used in an EtherChannel group. The second step is to create the logical EtherChannel port channel interface which contains the group of physical interfaces.

Topic 6.1.0 - The command channel-group mode active enables LACP unconditionally, and the command channel-group mode passive enables LACP only if the port receives an LACP packet from another device. The command channel-group mode desirable enables PAgP unconditionally, and the command channel-group mode auto enables PAgP only if the port receives a PAgP packet from another device.

Topic 6.1.0 - Source MAC to destination MAC load balancing and source IP to destination IP load balancing are two implementation methods used in EtherChannel technology.

Topic 6.1.0 - EtherChannel technology allows the grouping, or aggregating, of several Fast Ethernet or Gigabit switch ports into one logical channel.

Topic 6.1.0 - EtherChannel relies on existing switch ports, so there is no need to upgrade the links. Some configuration tasks are done on individual ports and some configuration tasks are done on the EtherChannel group. STP operates on EtherChannel in the same manner as it does on other redundant links.

Topic 6.1.0 - The combinations of modes that will form an EtherChannel are as follows: on/on, active/passive, active/active, desirable/auto, and desirable/desirable.

Topic 6.1.0 - The two protocols that can be used to form an EtherChannel are PAgP (Cisco proprietary) and LACP, also know as IEEE 802.3ad. STP (Spanning Tree Protocol) or RSTP (Rapid Spanning Tree Protocol) is used to avoid loops in a Layer 2 network. EtherChannel is the term that describes the bundling of two or more links that are treated as a single link for spanning tree and configuration.

Topic 6.1.0 - The command channel-group mode active enables LACP unconditionally, and the command channel-group mode passive enables LACP only if the port receives an LACP packet from another device. The command channel-group mode desirable enables PAgP unconditionally, and the command channel-group mode auto enables PAgP only if the port receives a PAgP packet from another device.

Topic 6.2.0 - All ports in an EtherChannel bundle must either be trunk ports or be access ports in the same VLAN. If VLAN pruning is enabled on the trunk, the allowed VLANs must be the same on both sides of the EtherChannel.

Topic 6.1.0 - The command channel-group mode active enables LACP unconditionally, and the command channel-group mode passive enables LACP only if the port receives an LACP packet from another device. The command channel-group mode desirable enables PAgP unconditionally, and the command channel-group mode auto enables PAgP only if the port receives a PAgP packet from another device.