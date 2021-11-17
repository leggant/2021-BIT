Connect-AzAccount -Tenant 450e6824-88ab-4ad2-914d-b0f385da600c -Subscription ee67cd86-3ab6-4382-81f9-9e62f569ffc6
get-AzContext
Select-AzSubscription -Tenant 450e6824-88ab-4ad2-914d-b0f385da600c
$cred = Get-Credential -UserName 'leggtc1' -Message "Enter a username and password for the virtual machine."

# -------------------------- CREATE VIRTUAL NETWORK -------------------------- #

$vnet = @{
    Name = 'vnet-leggtc1'
    ResourceGroupName = 'IN609OE1-LEGGTC1'
    Location = 'AustraliaEast'
    AddressPrefix = '192.168.0.0/16'    
}
$virtualNetwork = New-AzVirtualNetwork @vnet
$virtualNetwork | Set-AzVirtualNetwork

# ---------- THEN CREATE APPLICATION SECURITY GROUP FOR EACH SUBNET ---------- #

$AsgServer = New-AzApplicationSecurityGroup `
    -ResourceGroupName 'IN609OE1-LEGGTC1' `
    -Name 'AsgServers' `
    -Location 'AustraliaEast'

$AsgWork = New-AzApplicationSecurityGroup `
    -ResourceGroupName 'IN609OE1-LEGGTC1' `
    -Name 'AsgWork' `
    -Location 'AustraliaEast'


# ------------ SET RULES FOR INBOUND TRAFFIC AND OUTBOUND TRAFFIC ------------ #

# BLOCK WORKSTATIONS ACCESS TO WEBSERVER 

$workstationInbound = New-AzNetworkSecurityRuleConfig -Name workstation-block-inbound -Description "Deny web server access to workstation" `
    -Access Deny -Protocol * -Direction Inbound -Priority 101 -SourceAddressPrefix `
    '192.168.2.0/24' -SourcePortRange * -DestinationApplicationSecurityGroupId $AsgServer.id -DestinationPortRange *

$workstationInboundWeb = New-AzNetworkSecurityRuleConfig -Name workstation-web-all -Description "allowed web access workstation" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationApplicationSecurityGroupId $AsgServer.id -DestinationPortRange 80,443,22,3389

$webserverInboundRDP = New-AzNetworkSecurityRuleConfig -Name workstation-rdp-ssh -Description "allowed rdp and ssh workstation connections" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 120 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationApplicationSecurityGroupId $AsgWork.id -DestinationPortRange 22,3389


$webserverInbound = New-AzNetworkSecurityRuleConfig -Name web-rule-inbound -Description "Deny HTTP" `
    -Access Deny -Protocol Tcp -Direction Inbound -Priority 101 -SourceAddressPrefix `
    '192.168.2.0/24' -SourcePortRange * -DestinationApplicationSecurityGroupId $AsgServer.id -DestinationPortRange 80,443


# ------------------ ASSIGN RULES TO NETWORK SECURITY GROUP ------------------ #

$NSGABC = New-AzNetworkSecurityGroup `
    -ResourceGroupName 'IN609OE1-LEGGTC1' `
    -Location 'AustraliaEast' `
    -Name 'NSG-ABC' `
    -SecurityRules $workstationInbound, $workstationInboundWeb, $webserverInboundRDP

Set-AzNetworkSecurityGroup -NetworkSecurityGroup $NSGABC

# --------- CREATE A SUBNET THAT HAS THE VIRTUAL NETWORK AS A PARENT --------- #
# ------------------ AND USES THE NEW NETWORK SECURITY GROUP ----------------- #

$subnet1 = @{
    Name = 'subneta'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '192.168.1.0/24'
    NetworkSecurityGroup = $NSGABC
}

$subnet2 = @{
    Name  = 'subnetb'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '192.168.2.0/24'
    NetworkSecurityGroup = $NSGABC
}

$subnet3 = @{
    Name = 'subnetc'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '192.168.3.0/24'
    NetworkSecurityGroup = $NSGABC
}

# --------------- ADD NEW SUBNET CONFIG TO THE VIRTUAL NETWORK --------------- #

Add-AzVirtualNetworkSubnetConfig @subnet1 
Add-AzVirtualNetworkSubnetConfig @subnet2
Add-AzVirtualNetworkSubnetConfig @subnet3

$virtualNetwork | Set-AzVirtualNetwork

$virtualNetwork = Get-AzVirtualNetwork `
    -Name 'vnet-leggtc1' `
    -ResourceGroupName 'IN609OE1-LEGGTC1'

# The three Windows VMs  for ServerA, ServerB and ServerC specified on the Figure 1.

$ServerAIPconfig = New-AzNetworkInterfaceIpConfig `
    -Primary `
    -Name IPConfigA `
    -PrivateIpAddressVersion IPv4 `
    -PrivateIpAddress '192.168.1.5' `
    -SubnetId $virtualNetwork.Subnets[0].Id 

$serverAInterface = New-AzNetworkInterface `
    -Name "Server-Interface" `
    -ResourceGroupName "IN609OE1-LEGGTC1" `
    -Location "AustraliaEast" `
    -IpConfiguration $ServerAIPconfig `
    -NetworkSecurityGroup $NSGABC



$ServerANic = New-AzNetworkInterface `
    -Location 'AustraliaEast' `
    -Name 'Server-AV-M' `
    -ResourceGroupName IN609OE1-LEGGTC1 `
    -SubnetId $subnet1.Id `
    -ApplicationSecurityGroupId $NSGABC.Id

<#
a.	You need to create routing to route traffic from ServerB to ServerC via ServerA’s router appliance.
b.	Configure appropriate routing rules on the router appliance
#>

$publicNetworkIP = New-AzPublicIpAddress `
    -AllocationMethod Static `
    -ResourceGroupName 'IN609OE1-LEGGTC1' `
    -Location 'AustraliaEast' `
    -Name 'vnet-leggtc1' `
    -Sku Basic

<#
Task 5: Active directory Domain service (4)
a.	ServerA must have active directory domain services enabled.
b.	ServerB and ServerC must be member of the domain.
#>




<#		
Submissions: 
1.	All the commands/scripts for the Tasks.
2.	Screenshot of traceroute from ServerB to ServerC and vice versa, This should show the routes traversed.
3.	Screen shot of RDP session from ServerB to ServerC and vice versa.
4.	Screen shot of ssh session from your local computer to ServerA
5.	Screen shot of RDP session from your local computer to ServerA on active directory domain. 
You will need to include the above in a file and then submit it through Teams-Assignment tab 
#>