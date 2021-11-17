Connect-AzAccount -Tenant 450e6824-88ab-4ad2-914d-b0f385da600c -Subscription ee67cd86-3ab6-4382-81f9-9e62f569ffc6


$vnet = @{
    Name              = 'anthonyVN'
    ResourceGroupName = 'IN609OE1-LEGGTC1'
    Location          = 'AustraliaEast'
    AddressPrefix     = '192.168.0.0/16'    
}
$virtualNetwork = New-AzVirtualNetwork @vnet
$virtualNetwork | Set-AzVirtualNetwork

$Net = $virtualNetwork.Name
$Loc = $virtualNetwork.Location
$RGroup = $virtualNetwork.ResourceGroupName

$appServe = 'AsgServers'
$appWork = 'ASGWork'

$networkSecGroup = 'NSG-ABC'

$serverAconf = @{
    name = 'Server-A'
    install = 'Windows 2019 Server'
    subnet = 1
    addressSpace = '192.168.1.0/24'
    config = 'router appliance'
}

$serverBconf = @{
    name = 'Server-B'
    install = 'Windows 2019 Server'
    subnet = 2
    addressSpace = '192.168.2.0/24'
    config = 'webserver'
}

$serverCconf = @{
    name = 'Server-C'
    install = 'Windows 10 Workstation'
    subnet = 3
    addressSpace = '192.168.3.0/24'
    config = 'workstations'
}

$AsgServer = New-AzApplicationSecurityGroup `
    -ResourceGroupName $RGroup `
    -Name $appServe `
    -Location $Loc

$AsgWork = New-AzApplicationSecurityGroup `
    -ResourceGroupName $RGroup `
    -Name $appWork `
    -Location $Loc

$workstationInbound = New-AzNetworkSecurityRuleConfig -Name workstation-block-inbound -Description "Deny web server access to workstation" `
    -Access Deny -Protocol * -Direction Inbound -Priority 101 -SourceAddressPrefix `
    '192.168.2.0/24' -SourcePortRange * -DestinationApplicationSecurityGroupId $AsgServer.id -DestinationPortRange *

$workstationInboundWeb = New-AzNetworkSecurityRuleConfig -Name workstation-web-all -Description "allowed web access workstation" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationApplicationSecurityGroupId $AsgServer.id -DestinationPortRange 80,443,22,3389

$webserverInboundRDP = New-AzNetworkSecurityRuleConfig -Name workstation-rdp-ssh -Description "allowed rdp and ssh workstation connections" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 120 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationApplicationSecurityGroupId $AsgWork.id -DestinationPortRange 22,3389

$NSGABC = New-AzNetworkSecurityGroup `
    -ResourceGroupName $RGroup `
    -Location $Loc `
    -Name $networkSecGroup `
    -SecurityRules $workstationInbound, $workstationInboundWeb, $webserverInboundRDP

Set-AzNetworkSecurityGroup -NetworkSecurityGroup $NSGABC


$routeTablePublic = New-AzRouteTable `
  -Name 'ABCRouteTable' `
  -ResourceGroupName $RGroup `
  -location $Loc

Get-AzRouteTable `
  -ResourceGroupName $RGroup `
  -Name "ABCRouteTable" `
  | Add-AzRouteConfig `
  -Name "ToPrivateSubnetAddr" `
  -AddressPrefix 192.168.1.0/24 `
  -NextHopType "VirtualAppliance" `
  -NextHopIpAddress 10.1.2.4 `
 | Set-AzRouteTable


$subnet1 = @{
    Name = $serverAconf.name
    VirtualNetwork = $virtualNetwork
    AddressPrefix = $serverAconf.addressSpace
    NetworkSecurityGroup = $NSGABC
}

$subnet2 = @{
    Name = $serverBconf.name
    VirtualNetwork = $virtualNetwork
    AddressPrefix = $serverBconf.addressSpace
    NetworkSecurityGroup = $NSGABC
}

$subnet3 = @{
    Name = $serverCconf.name
    VirtualNetwork = $virtualNetwork
    AddressPrefix = $serverCconf.addressSpace
    NetworkSecurityGroup = $NSGABC
}
Add-AzVirtualNetworkSubnetConfig @subnet1 
Add-AzVirtualNetworkSubnetConfig @subnet2
Add-AzVirtualNetworkSubnetConfig @subnet3
$virtualNetwork | Set-AzVirtualNetwork

Set-AzVirtualNetworkSubnetConfig `
  -VirtualNetwork $virtualNetwork `
  -Name $subnet1.Name `
  -AddressPrefix $subnet1.AddressPrefix `
  -RouteTable $ABCRouteTable | `
Set-AzVirtualNetwork

$virtualNetwork = Get-AzVirtualNetwork `
  -ResourceGroupName $RGroup `
  -Name $Net

$subnetConfigA = Get-AzVirtualNetworkSubnetConfig `
  -Name $serverAconf.name `
  -VirtualNetwork $virtualNetwork

# Create the network interface.
$nic = New-AzNetworkInterface `
  -ResourceGroupName $RGroup `
  -Location $Loc `
  -Name 'myVmNva' `
  -SubnetId $subnetConfigA.Id `
  -EnableIPForwarding

  $vmConfig = New-AzVMConfig `
  -VMName 'myVmNva' `
  -VMSize Standard_DS2 | `
  Set-AzVMOperatingSystem -Windows `
    -ComputerName 'myVmNva' `
    -Credential $cred | `
  Set-AzVMSourceImage `
    -PublisherName MicrosoftWindowsServer `
    -Offer WindowsServer `
    -Skus 2019-Datacenter `
    -Version latest | `
  Add-AzVMNetworkInterface -Id $nic.Id

$vmNva = New-AzVM `
  -ResourceGroupName $RGroup `
  -Location $Loc `
  -VM $vmConfig `
  -AsJob

  New-AzVm `
  -ResourceGroupName $RGroup `
  -Location $Loc `
  -VirtualNetworkName $net `
  -SubnetName $serverAconf.name `
  -ImageName "Win2016Datacenter" `
  -Name "myVmPublic" `
  -AsJob

  New-AzVm `
  -ResourceGroupName $RGroup `
  -Location $Loc `
  -VirtualNetworkName $net `
  -SubnetName $serverBconf.name `
  -ImageName "Win2016Datacenter" `
  -Name "myVmPrivate"

 $ip =  Get-AzPublicIpAddress `
  -Name myVmPrivate `
  -ResourceGroupName $RGroup `
  | Select IpAddress
