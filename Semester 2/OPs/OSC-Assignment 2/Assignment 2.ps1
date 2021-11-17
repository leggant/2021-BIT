Connect-AzAccount -Tenant 450e6824-88ab-4ad2-914d-b0f385da600c -Subscription ee67cd86-3ab6-4382-81f9-9e62f569ffc6
Get-AzSubscription
$cred = Get-Credential -UserName 'leggtc1' -Message "Enter a username and password for the virtual machine."
Get-Credential
# -------------------------- CREATE VIRTUAL NETWORK -------------------------- #

$vnet = @{
    Name = 'vnet-leggtc1'
    ResourceGroupName = 'IN609OE1-LEGGTC1'
    Location = 'AustraliaEast'
    AddressPrefix = '192.168.0.0/16'    
}
$virtualNetwork = New-AzVirtualNetwork @vnet
$virtualNetwork | Set-AzVirtualNetwork

$Net = $virtualNetwork.Name
$Loc = $virtualNetwork.Location
$RGroup = $virtualNetwork.ResourceGroupName

# ---------- THEN CREATE APPLICATION SECURITY GROUP FOR EACH SUBNET ---------- #

$ASGServe = 'ASGServers'
$ASGWork = 'ASGWork'

$AsgServer = New-AzApplicationSecurityGroup `
    -ResourceGroupName $RGroup `
    -Name $ASGServe `
    -Location $Loc 

$AsgWork = New-AzApplicationSecurityGroup `
    -ResourceGroupName $RGroup `
    -Name $ASGWork `
    -Location $Loc


# ------------ SET RULES FOR INBOUND TRAFFIC AND OUTBOUND TRAFFIC ------------ #

# INBOUND RULES

$workstationInbound = New-AzNetworkSecurityRuleConfig -Name workstation-secure-access -Description "accept ssh/rdp access to workstation" `
    -Access Allow -Protocol TCP -Direction Inbound -Priority 101 -SourceAddressPrefix `
    * -SourcePortRange 22,3389 -DestinationApplicationSecurityGroupId $AsgServer.id -DestinationPortRange 22, 3389

$workstationRDP = New-AzNetworkSecurityRuleConfig -Name workstation-RDP -Description "allowed rdp access workstation" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 -SourceApplicationSecurityGroupId $AsgServer.id `
    -SourcePortRange 3389 -DestinationApplicationSecurityGroupId $AsgWork.id -DestinationPortRange 3389

$webserverBlockWorkStation = New-AzNetworkSecurityRuleConfig -Name workstation-webserver-block -Description "block workstation webserver connections" `
    -Access Deny -Protocol * -Direction Inbound -Priority 120 -SourceApplicationSecurityGroupId $AsgWork.id `
    -SourcePortRange 8080,80 -DestinationApplicationSecurityGroupId $AsgServers.id -DestinationPortRange 8080,80

# OUTBOUND RULES

$BlockWorkStationWebserver = New-AzNetworkSecurityRuleConfig -Name webserver-block-workstation -Description "block workstation webserver connections" `
    -Access Deny -Protocol * -Direction Outbound -Priority 130 -SourceApplicationSecurityGroupId $AsgWork.id `
    -SourcePortRange * -DestinationAddressPrefix 192.168.2.0/24 -DestinationPortRange *

# ------------------ ASSIGN RULES TO NETWORK SECURITY GROUP ------------------ #

$NSGABC = New-AzNetworkSecurityGroup `
    -ResourceGroupName $RGroup `
    -Location $Loc `
    -Name 'NSG-ABC' `

    
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $NSGABC


# Create a new route table

$routeTablePublic = New-AzRouteTable `
  -Name 'ABCINT_RouteTable' `
  -ResourceGroupName $RGroup `
  -location $Loc

Get-AzRouteTable `
  -ResourceGroupName $RGroup `
  -Name "ABCRoute" `
  | Add-AzRouteConfig `
  -Name "SubnetA" `
  -AddressPrefix 192.168.1.0/24 `
  -NextHopType "VirtualAppliance" `
  -NextHopIpAddress 10.1.2.4 `
 | Set-AzRouteTable




# --------- CREATE A SUBNET THAT HAS THE VIRTUAL NETWORK AS A PARENT --------- #
# ------------------ AND USES THE NEW NETWORK SECURITY GROUP ----------------- #

$subnet1 = @{
    Name = 'subnet1'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '192.168.1.0/24'
    NetworkSecurityGroup = $NSGABC
}

$subnet2 = @{
    Name  = 'subnet2'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '192.168.2.0/24'
}

$subnet3 = @{
    Name = 'subnet3'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '192.168.3.0/24'
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
    -PrivateIpAddress '192.168.1.4' `
    -SubnetId $virtualNetwork.Subnets[0].Id 

$serverAInterface = New-AzNetworkInterface `
    -Name "Server-Interface" `
    -ResourceGroupName "IN609OE1-LEGGTC1" `
    -Location "AustraliaEast" `
    -IpConfiguration $ServerAIPconfig `
    -NetworkSecurityGroup $NSGABC

$ServerANic = New-AzNetworkInterface `
    -Location 'AustraliaEast' `
    -Name 'Server-A-VM' `
    -ResourceGroupName IN609OE1-LEGGTC1 `
    -SubnetId $subnet1.Id `
    -ApplicationSecurityGroupId $NSGABC.Id

New-AzVM -ResourceGroupName IN609OE1-LEGGTC1 -Location $Loc -Name ServerA -VirtualNetworkName ASGServers -SubnetName subnet1 -SecurityGroupName NSG-ABC -Image Win2019Datacenter -Credential $cred -OpenPorts 3389


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
