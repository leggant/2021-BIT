# Inter-VLAN Routing
---

Hosts in one VLAN cannot communicate with hosts in another VLAN unless there is a router or a Layer 3 switch to provide routing services. Inter-VLAN routing is the process of forwarding network traffic from one VLAN to another VLAN. Three options include legacy, router-on-a-stick, and Layer 3 switch using SVIs. 

The modern method is Inter-VLAN routing on a Layer 3 switch using SVIs. The SVI is created for a VLAN that exists on the switch. The SVI performs the same functions for the VLAN as a router interface. It provides Layer 3 processing for packets being sent to or from all switch ports associated with that VLAN.

---
## Legacy

Legacy used a router with multiple Ethernet interfaces. Each router interface was connected to a switch port in different VLANs. Requiring one physical router interface per VLAN quickly exhausts the physical interface capacity of a router.

---
## Router-on-a-Stick 

The ‘router-on-a-stick’ inter-VLAN routing method only requires one physical Ethernet interface to route traffic between multiple VLANs on a network. A Cisco IOS router Ethernet interface is configured as an 802.1Q trunk and connected to a trunk port on a Layer 2 switch. The router interface is configured using subinterfaces to identify routable VLANs. The configured subinterfaces are software-based virtual interfaces, associated with a single physical Ethernet interface. 

### VLAN and Trunking Configuration

1. Create and name the VLANs.

		S1(config)# vlan 10
		S1(config-vlan)# name LAN10
		S1(config-vlan)# exit
		S1(config)# vlan 20
		S1(config-vlan)# name LAN20
		S1(config-vlan)# exit
		S1(config)# vlan 99
		S1(config-vlan)# name Management
		S1(config-vlan)# exit
		S1(config)#

2. Create the management interface.

	Next, the management interface is created on VLAN 99 along with the default gateway of R1.

		S1(config)# interface vlan 99
		S1(config-if)# ip add 192.168.99.2 255.255.255.0
		S1(config-if)# no shut
		S1(config-if)# exit
		S1(config)# ip default-gateway 192.168.99.1
		S1(config)#

3. Configure access ports.

	Next, port Fa0/6 connecting to PC1 is configured as an access port in VLAN 10. Assume PC1 has been configured with the correct IP address and default gateway.

		S1(config)# interface fa0/6
		S1(config-if)# switchport mode access
		S1(config-if)# switchport access vlan 10
		S1(config-if)# no shut
		S1(config-if)# exit
		S1(config)#

4. Configure trunking ports.

	Finally, ports Fa0/1 connecting to S2 and Fa05 connecting to R1 are configured as trunk ports.
		
		S1(config)# interface fa0/1
		S1(config-if)# switchport mode trunk
		S1(config-if)# no shut
		S1(config-if)# exit
		S1(config)# interface fa0/5
		S1(config-if)# switchport mode trunk
		S1(config-if)# no shut
		S1(config-if)# end
		*Mar  1 00:23:43.093: %LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/1, changed state to up
		*Mar  1 00:23:44.511: %LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/5, changed state to up

5. Configure Switch 2

		S2(config)# vlan 10
		S2(config-vlan)# name LAN10
		S2(config-vlan)# exit
		S2(config)# vlan 20
		S2(config-vlan)# name LAN20
		S2(config-vlan)# exit
		S2(config)# vlan 99
		S2(config-vlan)# name Management
		S2(config-vlan)# exit


		S2(config)#
		S2(config)# interface vlan 99
		S2(config-if)# ip add 192.168.99.3 255.255.255.0
		S2(config-if)# no shut
		S2(config-if)# exit


		S2(config)# ip default-gateway 192.168.99.1
		S2(config)# interface fa0/18
		S2(config-if)# switchport mode access
		S2(config-if)# switchport access vlan 20
		S2(config-if)# no shut
		S2(config-if)# exit


		S2(config)# interface fa0/1
		S2(config-if)# switchport mode trunk
		S2(config-if)# no shut
		S2(config-if)# exit
		S2(config-if)# end
		*Mar  1 00:23:52.137: %LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/1, changed state to up

6. Router Subinterface Configuration

	The router-on-a-stick method requires you to create a subinterface for each VLAN to be routed.
	
	A subinterface is created using the interface interface_id.subinterface_id global configuration mode command. The subinterface syntax is the physical interface followed by a period and a subinterface number. Although not required, it is customary to match the subinterface number with the VLAN number.
	
	Each subinterface is then configured with the following two commands:
	
	encapsulation dot1q vlan_id [native] - This command configures the subinterface to respond to 802.1Q encapsulated traffic from the specified vlan-id. The native keyword option is only appended to set the native VLAN to something other than VLAN 1.
	ip address ip-address subnet-mask - This command configures the IPv4 address of the subinterface. This address typically serves as the default gateway for the identified VLAN.
	Repeat the process for each VLAN to be routed. Each router subinterface must be assigned an IP address on a unique subnet for routing to occur.
	
	When all subinterfaces have been created, enable the physical interface using the no shutdown interface configuration command. If the physical interface is disabled, all subinterfaces are disabled.
	
	In the following configuration, the R1 G0/0/1 subinterfaces are configured for VLANs 10, 20, and 99.

		R1(config)# interface G0/0/1.10
		R1(config-subif)# description Default Gateway for VLAN 10
		R1(config-subif)# encapsulation dot1Q 10
		R1(config-subif)# ip add 192.168.10.1 255.255.255.0
		R1(config-subif)# exit
		R1(config)#
		R1(config)# interface G0/0/1.20
		R1(config-subif)# description Default Gateway for VLAN 20
		R1(config-subif)# encapsulation dot1Q 20
		R1(config-subif)# ip add 192.168.20.1 255.255.255.0
		R1(config-subif)# exit
		R1(config)#
		R1(config)# interface G0/0/1.99
		R1(config-subif)# description Default Gateway for VLAN 99
		R1(config-subif)# encapsulation dot1Q 99
		R1(config-subif)# ip add 192.168.99.1 255.255.255.0
		R1(config-subif)# exit
		R1(config)#
		R1(config)# interface G0/0/1
		R1(config-if)# description Trunk link to S1
		R1(config-if)# no shut
		R1(config-if)# end

7. Verify Connectivity

	From a host, verify connectivity to a host in another VLAN using the ping command. It is a good idea to first verify the current host IP configuration using the ipconfig Windows host command.

		show ip route
		show ip interface brief
		show interfaces
		show interfaces trunk

	Verify that the subinterfaces are appearing in the routing table of R1 by using the show ip route command
		
		R1# show ip route | begin Gateway
	output confirms that the subinterfaces have the correct IPv4 address configured, and that they are operational

		R1# show ip interface brief | include up

		R1# show interfaces g0/0/1.10

	verify the active trunk links on a Layer 2 switch by using the show interfaces trunk command, as shown in the output. The output confirms that the link to R1 is trunking for the required VLANs

		S1# show interfaces trunk
		Port        Mode             Encapsulation  Status        Native vlan
		Fa0/1       on               802.1q         trunking      1
		Fa0/5       on               802.1q         trunking      1
		Port        Vlans allowed on trunk
		Fa0/1       1-4094
		Fa0/5       1-4094
		Port        Vlans allowed and active in management domain
		Fa0/1       1,10,20,99
		Fa0/5       1,10,20,99
		Port        Vlans in spanning tree forwarding state and not pruned
		Fa0/1       1,10,20,99
		Fa0/5       1,10,20,99
		S1#
---

# Layer 3 Switch Inter-VLAN Routing

Inter-VLAN routing using the router-on-a-stick method is simple to implement for a small to medium-sized organization. However, a large enterprise requires a faster, much more scalable method to provide inter-VLAN routing. Layer 3 switches use hardware-based switching to achieve higher-packet processing rates than routers. Layer 3 switches are also commonly implemented in enterprise distribution layer wiring closets.

Inter-VLAN Routing using Layer 3 Switches

Enterprise campus LANs use Layer 3 switches to provide inter-VLAN routing. Layer 3 switches use hardware-based switching to achieve higher-packet processing rates than routers. Capabilities of a Layer 3 switch include routing from one VLAN to another using multiple switched virtual interfaces (SVIs) and converting a Layer 2 switchport to a Layer 3 interface (i.e., a routed port). 

To provide inter-VLAN routing, Layer 3 switches use SVIs. SVIs are configured using the same `interface vlan vlan-id` command used to create the management SVI on a Layer 2 switch. A Layer 3 SVI must be created for each of the routable VLANs. 

To configure a switch with VLANS and trunking, complete the following steps: 
1. create the VLANS
2. create the SVI VLAN interfaces
3. configure access ports
4. enable IP routing. 

From a host, verify connectivity to a host in another VLAN using the ping command. 

Next, verify connectivity with the host using the `ping` Windows host command. 

VLANs must be advertised using static or dynamic routing. To enable routing on a Layer 3 switch, a routed port must be configured. A routed port is created on a Layer 3 switch by disabling the switchport feature on a Layer 2 port that is connected to another Layer 3 device. The interface can be configured with an IPv4 configuration to connect to a router or another Layer 3 switch. To configure a Layer 3 switch to route with a router, follow these steps: configure the routed port, enable routing, configure routing, verify routing, and verify connectivity.

Capabilities of a Layer 3 switch include the ability to do the following:

1. Route from one VLAN to another using multiple switched virtual interfaces (SVIs).
2. Convert a Layer 2 switchport to a Layer 3 interface (i.e., a routed port). A routed port is similar to a physical interface on a Cisco IOS router.

To provide inter-VLAN routing, Layer 3 switches use SVIs. SVIs are configured using the same interface vlan vlan-id command used to create the management SVI on a Layer 2 switch. A Layer 3 SVI must be created for each of the routable VLANs.

---

# Router-on-a-Stick Inter-VLAN Routing

To configure a switch with VLANs and trunking, complete the following steps: create and name the VLANs, create the management interface, configure access ports, and configure trunking ports. The router-on-a-stick method requires a subinterface to be created for each VLAN to be routed. A subinterface is created using the `interface interface_id subinterface_id` global configuration mode command. 

Each router subinterface must be assigned an IP address on a unique subnet for routing to occur. When all subinterfaces have been created, the physical interface must be enabled using the `no shutdown` interface configuration command. 

## Troubleshoot and Verify

From a host, verify connectivity to a host in another VLAN using the `ping` command. Use `ping` to verify connectivity with the host and the switch. To verify and troubleshoot use the `show ip route`, `show ip interface brief`, `show interfaces`, and `show interfaces trunk` commands.

Troubleshoot Inter-VLAN Routing

connectivity issues such as missing VLANs, switch trunk port issues, switch access port issues, and router configuration issues will break connections. A VLAN could be missing if it was not created, it was accidently deleted, or it is not allowed on the trunk link. Another issue for inter-VLAN routing includes misconfigured switch ports. 

In a legacy inter-VLAN solution, a misconfigured switch port could be caused when the connecting router port is not assigned to the correct VLAN. 

With a router-on-a-stick solution, the most common cause is a misconfigured trunk port. When a problem is suspected with a switch access port configuration, use `ping` and `show interfaces interface-id switchport` commands to identify the problem. Router configuration problems with router-on-a-stick configurations are usually related to subinterface misconfigurations. Verify the subinterface status using the `show ip interface brief` command

