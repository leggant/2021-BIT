# Basic Config

## Distribution Switch-1

```
en
conf t
no ip domain-lookup
spanning-tree mode rapid-pvst
int range f0/1-24, g0/1-2
duplex full
shutdown
end
conf t
vlan 10
name Server
vlan 20
name Finance
vlan 30
name Sales
vlan 40
name Personnel
vlan 50
name Admin
vlan 99
name Native
vlan 100
name Management
end
conf t
line con 0
logging synchronous
password cisco
login
line vty 0 15
logging synchronous
password cisco
login
end
copy run start
en
conf t
int range f0/1-24, g0/1-2
duplex full
end 
copy run start

```

spanning-tree portfast
spanning-tree bpduguard enable





int port-channel 1

switchport mode trunk

switchport nonegotiate

switchport trunk allowed vlan 10,20,30,40,50,99,100

int port-channel 2

switchport mode trunk

switchport nonegotiate

switchport trunk allowed vlan 10,20,30,40,50,99,100

int port-channel 3

switchport mode trunk

switchport nonegotiate

switchport trunk allowed vlan 10,20,30,40,50,99,100

int port-channel 4

switchport mode trunk

switchport nonegotiate

switchport trunk allowed vlan 10,20,30,40,50,99,100

conf t
vlan 10
name Server
vlan 20
name Finance
vlan 30
name Sales
vlan 40
name Personnel
vlan 50
name Admin
vlan 99
name Native
vlan 100
name Management
end
copy run start

enable
conf t
line con 0
logging synchronous
password cisco
login
line vty 0 15
logging synchronous
password cisco
login
do copy run start

spanning-tree portfast
spanning-tree bpduguard enable

### SSH Config

ip domain-name admin
crypto key generate rsa
1024
user admin privilege 15 secret cisco
line vty 0 4
transport input ssh
login local
exit
ip ssh version 2

enable
conf t

# Trunk

int range f0/1-4,f0/10-11,f/21-24
switchport mode trunk
switchport trunk native vlan 99
switchport nonegotiate 
switchport trunk allowed vlan 10,20,30,40,50,99,100
end


### Port Security

switchport port-security violation shutdown
switchport port-security maximum 2 // limits max hosts on a port
switchport port-security mac-address sticky  // switch actively monitors and records mac addresses
switchport port-security  // enables

show port-security interface f0/1

#### spanning tree mode 

int range ?
spanning-tree portfast
spanning-tree bpduguard enable

enable
conf t
spanning-tree mode rapid-pvst
do copy run start