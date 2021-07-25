# DHCPv4 Concepts

## Intro 

The DHCPv4 server dynamically assigns, or leases, an IPv4 address from a pool of addresses for a limited period of time chosen by the server, or until the client no longer needs the address.

Clients lease the information from the server for an administratively defined period. Administrators configure DHCPv4 servers to set the leases to time out at different intervals. The lease is typically anywhere from 24 hours to a week or more. When the lease expires, the client must ask for another address, although the client is typically reassigned the same address. DHCPv4 works in a client/server mode. When a client communicates with a DHCPv4 server, the server assigns or leases an IPv4 address to that client. The client connects to the network with that leased IPv4 address until the lease expires. The client must contact the DHCP server periodically to extend the lease. This lease mechanism ensures that clients that move or power off do not keep addresses that they no longer need. When a lease expires, the DHCP server returns the address to the pool where it can be reallocated as necessary.

## Steps to Obtain a Lease

![DHCP Diagram](https://github.com/leggant/2021-BIT/blob/main/Routing-Switching-Wireless/linkedImages/dhcp1.jpg?raw=true "DHCP Lease")

When the client boots (or otherwise wants to join a network), it begins a four-step process to obtain a lease:

1. DHCP Discover (DHCPDISCOVER)

	The client starts the process using a broadcast DHCPDISCOVER message with its own MAC 		address to discover available DHCPv4 servers. Because the client has no valid IPv4 information at bootup, it uses Layer 2 and Layer 3 broadcast addresses to communicate with the server. The purpose of the DHCPDISCOVER message is to find DHCPv4 servers on the network.
2. DHCP Offer (DHCPOFFER)

	When the DHCPv4 server receives a DHCPDISCOVER message, it reserves an available IPv4 address to lease to the client. The server also creates an ARP entry consisting of the MAC address of the requesting client and the leased IPv4 address of the client. The DHCPv4 server sends the binding DHCPOFFER message to the requesting client.
3. DHCP Request (DHCPREQUEST)

	When the client receives the DHCPOFFER from the server, it sends back a DHCPREQUEST message. This message is used for both lease origination and lease renewal. When used for lease origination, the DHCPREQUEST serves as a binding acceptance notice to the selected server for the parameters it has offered and an implicit decline to any other servers that may have provided the client a binding offer. Many enterprise networks use multiple DHCPv4 servers. The DHCPREQUEST message is sent in the form of a broadcast to inform this DHCPv4 server and any other DHCPv4 servers about the accepted offer.
4. DHCP Acknowledgment (DHCPACK)

	On receiving the DHCPREQUEST message, the server may verify the lease information with an ICMP ping to that address to ensure it is not being used already, it will create a new ARP entry for the client lease, and reply with a DHCPACK message. The DHCPACK message is a duplicate of the DHCPOFFER, except for a change in the message type field. When the client receives the DHCPACK message, it logs the configuration information and may perform an ARP lookup for the assigned address. If there is no reply to the ARP, the client knows that the IPv4 address is valid and starts using it as its own.

## Steps to Renew a Lease

![DHCP Diagram](https://github.com/leggant/2021-BIT/blob/main/Routing-Switching-Wireless/linkedImages/dhcp2.jpg?raw=true "DHCP Lease")

Prior to lease expiration, the client begins a two-step process to renew the lease with the DHCPv4 server, as shown in the figure:

1. DHCP Request (DHCPREQUEST)

	Before the lease expires, the client sends a DHCPREQUEST message directly to the DHCPv4 server that originally offered the IPv4 address. If a DHCPACK is not received within a specified amount of time, the client broadcasts another DHCPREQUEST so that one of the other DHCPv4 servers can extend the lease.

2. DHCP Acknowledgment (DHCPACK)

	On receiving the DHCPREQUEST message, the server verifies the lease information by returning a DHCPACK.

Note: These messages (primarily the DHCPOFFER and DHCPACK) can be sent as unicast or broadcast according to IETF RFC 2131. 

# DHCPv4 Server

Use the following steps to configure a Cisco IOS DHCPv4 server:

1. Exclude IPv4 addresses
2. Define a DHCPv4 pool name
3. Configure the DHCPv4 pool

- Step 1. Exclude IPv4 Addresses

	The router functioning as the DHCPv4 server assigns all IPv4 addresses in a DHCPv4 address pool unless it is configured to exclude specific addresses. Typically, some IPv4 addresses in a pool are assigned to network devices that require static address assignments. Therefore, these IPv4 addresses should not be assigned to other devices. The command syntax to exclude IPv4 addresses is the following:

	`Router(config)# ip dhcp excluded-address low-address high-address`

	A single address or a range of addresses can be excluded by specifying the low-address and high-address of the range. 
	
	Excluded addresses should be those addresses that are assigned to routers, servers, printers, and other devices that have been, or will be, manually configured. You can also enter the command multiple times.

- Step 2. Define a DHCPv4 Pool Name

	Configuring a DHCPv4 server involves defining a pool of addresses to assign.

	the `ip dhcp pool pool-name` command creates a pool with the specified name and puts the router in DHCPv4 configuration mode, which is identified by the prompt `Router(dhcp-config)#`.

	The command syntax to define the pool is the following:
	```
	Router(config)# ip dhcp pool pool-name
	Router(dhcp-config)# 
	```
- Step 3. Configure the DHCPv4 Pool

	The address pool and default gateway router must be configured. Use the `network` statement to define the range of available addresses. Use the `default-router` command to define the default gateway router. Typically, the gateway is the LAN interface of the router closest to the client devices. One gateway is required, but you can list up to eight addresses if there are multiple gateways.

	Other DHCPv4 pool commands are optional. For example, the IPv4 address of the DNS server that is available to a DHCPv4 client is configured using the `dns-server` command. The `domain-name` command is used to define the domain name. The duration of the DHCPv4 lease can be changed using the `lease` command. The default lease value is one day. The `netbios-name-server` command is used to define the NetBIOS WINS server.


|Task|	IOS Command|
|---|-----|
|Define the address pool.	| network network-number [mask \ prefix-length]|
|Define the default router or gateway.	|default-router address [ address2….address8]|
|Define a DNS server.	|dns-server address [ address2…address8]|
|Define the domain name.	|domain-name domain|
|Define the duration of the DHCP lease.	|lease {days [hours [ minutes]] \ infinite}|
|Define the NetBIOS WINS server.	| netbios-name-server address [ address2…address8]|

Note: Microsoft recommends not deploying WINS, instead configure DNS for Windows name resolution and decommission WINS.

### Configuration Example

<<<<<<< Updated upstream
![Example Diagram](https://github.com/leggant/2021-BIT/blob/main/Routing-Switching-Wireless/linkedImages/dhcp-config-example-1.jpg?raw=true "DHCP Config Example")
=======
[Example Diagram](https://github.com/leggant/2021-BIT/blob/main/Routing-Switching-Wireless/linkedImages/dhcp-config-example-1.jpg?raw=true "DHCP Config Example")

---

>>>>>>> Stashed changes
