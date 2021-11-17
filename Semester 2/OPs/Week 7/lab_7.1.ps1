Connect-AzAccount -Tenant 450e6824-88ab-4ad2-914d-b0f385da600c -Subscription ee67cd86-3ab6-4382-81f9-9e62f569ffc6
$cred = Get-Credential -UserName 'leggtc1' -Message "Enter a username and password for the virtual machine."

# -------------------------- CREATE VIRTUAL NETWORK -------------------------- #

$vnet = @{
    Name              = 'anthonyVN'
    ResourceGroupName = 'IN609OE1-LEGGTC1'
    Location          = 'AustraliaEast'
    AddressPrefix     = '10.1.0.0/16'    
}
$virtualNetwork = New-AzVirtualNetwork @vnet
$virtualNetwork | Set-AzVirtualNetwork

# ---------- THEN CREATE APPLICATION SECURITY GROUP FOR EACH SERVER ---------- #

$webAsg = New-AzApplicationSecurityGroup `
    -ResourceGroupName 'IN609OE1-LEGGTC1' `
    -Name 'anthonywebASGServers' `
    -Location 'AustraliaEast'

$mgtAsg = New-AzApplicationSecurityGroup `
    -ResourceGroupName 'IN609OE1-LEGGTC1' `
    -Name 'anthonyMgtASGServers' `
    -Location 'AustraliaEast'

# ------------ SET RULES FOR INBOUND TRAFFIC AND OUTBOUND TRAFFIC ------------ #

$webRule = New-AzNetworkSecurityRuleConfig `
    -Name "Allow-Web-All" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 100 `
    -SourceAddressPrefix Internet `
    -SourcePortRange * `
    -DestinationApplicationSecurityGroupId $webAsg.id `
    -DestinationPortRange 80, 443
 
$mgmtRule = New-AzNetworkSecurityRuleConfig `
    -Name "Allow-RDP-All" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 110 `
    -SourceAddressPrefix Internet `
    -SourcePortRange * `
    -DestinationApplicationSecurityGroupId $mgtAsg.id `
    -DestinationPortRange 3389

# ------------------ ASSIGN RULES TO NETWORK SECURITY GROUP ------------------ #

$newNsg = New-AzNetworkSecurityGroup `
    -ResourceGroupName 'IN609OE1-LEGGTC1' `
    -Location 'AustraliaEast' `
    -Name 'anthonyNsg' `
    -SecurityRules $webRule, $mgmtRule
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $newNsg

# --------- CREATE A SUBNET THAT HAS THE VIRTUAL NETWORK AS A PARENT --------- #
# ------------------ AND USES THE NEW NETWORK SECURITY GROUP ----------------- #

$subnet = @{
    Name                 = 'leggtc1Subnet'
    VirtualNetwork       = $virtualNetwork
    AddressPrefix        = '10.1.0.0/24'
    NetworkSecurityGroup = $newNsg
}


# --------------- ADD NEW SUBNET CONFIG TO THE VIRTUAL NETWORK --------------- #

$antsubnet = Add-AzVirtualNetworkSubnetConfig @subnet
$virtualNetwork | Set-AzVirtualNetwork
$antsubnet | Set-AzVirtualNetwork

$virtualNetwork = Get-AzVirtualNetwork `
    -Name 'anthonyVN' `
    -ResourceGroupName 'IN609OE1-LEGGTC1'


# ------------------------- CREATE PUBLIC IP ADDRESS ------------------------- #
$publicIPWeb = New-AzPublicIpAddress `
    -AllocationMethod Static `
    -ResourceGroupName 'IN609OE1-LEGGTC1' `
    -Location 'AustraliaEast' `
    -Name 'antVMWebip' `
    -Sku Basic

$publicIPMGT = New-AzPublicIpAddress `
    -AllocationMethod Static `
    -ResourceGroupName 'IN609OE1-LEGGTC1' `
    -Location 'AustraliaEast' `
    -Name 'antVMMgmtip' `
    -Sku Basic

# ---------------- ASSIGN PUBLIC IP ADDRESS TO SUBNET AND NIC ---------------- #

$webVMNic = New-AzNetworkInterface `
    -Location 'AustraliaEast' `
    -Name 'antVMWeb' `
    -ResourceGroupName IN609OE1-LEGGTC1 `
    -SubnetId $virtualNetwork.Subnets[0].Id `
    -ApplicationSecurityGroupId $webAsg.Id `
    -PublicIpAddressId $publicIPWeb.Id

$mgmtNic = New-AzNetworkInterface `
    -Location 'AustraliaEast' `
    -Name 'antVMMgmt' `
    -ResourceGroupName 'IN609OE1-LEGGTC1' `
    -SubnetId $virtualNetwork.Subnets[0].Id `
    -applicationSecurityGroupId $mgtAsg.Id `
    -PublicIpAddressId $publicIPMGT.Id

# ------------------------ CREATE CONFIGS FOR NEW VMS ------------------------ #

$webVmConfig = New-AzVMConfig `
    -VMName 'antVMWeb' `
    -VMSize 'Standard_DS1_V2' | `
    Set-AzVMOperatingSystem -Windows `
    -ComputerName 'antVMWebvm' `
    -Credential $cred | `
    Set-AzVMSourceImage `
    -PublisherName MicrosoftWindowsServer `
    -Offer WindowsServer `
    -Skus 2019-Datacenter `
    -Version latest | `
    Add-AzVMNetworkInterface `
    -Id $webVMNic.Id

New-AzVM `
    -ResourceGroupName 'IN609OE1-LEGGTC1' `
    -Location 'AustraliaEast' `
    -VM $webVmConfig `
    -AsJob

$mangVmConfig = New-AzVMConfig `
    -VMName 'antVMMgmt' `
    -VMSize latest | `
    Set-AzVMOperatingSystem -Windows `
    -ComputerName antVMMgmt `
    -Credential $cred | `
    Set-AzVMSourceImage `
    -PublisherName MicrosoftWindowsServer `
    -Offer WindowsServer `
    -Skus 2019-Datacenter `
    -Version latest | `
    Add-AzVMNetworkInterface `
    -Id $mgmtNic.Id 

New-AzVM `
    -ResourceGroupName 'IN609OE1-LEGGTC1' `
    -Location 'AustraliaEast' `
    -VM $mangVmConfig `
    -AsJob

$webPublicIP = Get-AzPublicIpAddress -Name antVMWebip -ResourceGroupName IN609OE1-LEGGTC1 | Select-Object IpAddress
$mantPublicIP = Get-AzPublicIpAddress -Name antVMMgmtip -ResourceGroupName IN609OE1-LEGGTC1 | Select-Object IpAddress

mstsc /v:$webPublicIP


# --------------------------- CREATE A ROUTE TABLE --------------------------- #

$routeTable = New-AzRouteTable `
    -ResourceGroupName IN609OE1-LEGGTC1 `
    -Name 'abcroutetable' `
    -Location 'Australia East'

Get-AzRouteTable `
  -ResourceGroupName IN609OE1-LEGGTC1 `
  -Name "abcroutetable" `
  | Add-AzRouteConfig `
  -Name "ToPrivateSubnet" `
  -AddressPrefix 10.0.1.0/24 `
  -NextHopType "VirtualAppliance" `
  -NextHopIpAddress 10.0.2.4 `
 | Set-AzRouteTable
