# Layer 3 Switches
---

## Configure Routed Port
### Connects to other networks/devices outside network

```
MLS(config)# interface g0/2
MLS(config-if)# no switchport
MLS(config-if)# ip address 209.165.200.225 255.255.255.252
```

### Check Connectivity
`MLS# ping 209.165.200.226`

# Part-2 Config Inter-Vlan Routing

## Add VLANS

Vlan 10 - Name: Staff
VLAN 20 - Name: Student
VLAN 30 - Name Faculty

## Configure SVIs

```
MLS(config)# interface vlan 10
MLS(config-if)# ip address 192.168.10.254 255.255.255.0
MLS(config-if)# ipv6 address 2001:db8:acad:10::1/64
...
MLS(config)# interface vlan 99
MLS(config-if)# ip address 192.168.99.254 255.255.255.0
MLS(config)# interface g0/2
MLS(config-if)# ip address 209.165.200.225 255.255.255.252
MLS(config-if)# ipv6 address 2001:db8:acad:a::1/64
```
# Part 3

## Configure Trunking

Trunk configuration differs on the Layer 3 switch. Trunking interface needs to be encapsulated with the dot1q protocol, however it is not necessary to specify VLAN numbers as it is when working with a router and subinterfaces.

```
MLS(config)# interface g0/1
MLS(config-if)# switchport mode trunk
MLS(config-if)# switchport trunk native vlan 99
MLS(config-if)# switchport trunk encapsulation dot1q
```

# Step 4: Configure trunking

## Configure Trunking on the external network switch

```
S1(config)#int g0/1
S1(config-if)#switchport mode trunk
S1(config-if)#switchport trunk native vlan 99
```

# Step 5: Enable routing

`show ip route`

```
MLS(config)#ip routing
MLS(config)#ipv6 unicast-routing 
```
# Step 6: Verify end-to-end connectivity.

1. `show ip route`
2. `show ipv6 route`