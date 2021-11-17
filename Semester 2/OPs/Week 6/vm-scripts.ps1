Connect-AzAccount -Tenant 450e6824-88ab-4ad2-914d-b0f385da600c -Subscription ee67cd86-3ab6-4382-81f9-9e62f569ffc6
Get-AzSubscription
$me = Get-Credential -UserName leggtc1 -Message 'me'

$tags = @{}
$tags.Add('ant','vm')
$antsubnet = New-AzVirtualNetworkSubnetConfig -Name 'AzureBastionSubnet' -AddressPrefix '10.1.0.0/24'
$virtualNetwork = New-AzVirtualNetwork -Name "leggtc1-vn" -ResourceGroupName 'IN609OE1-LEGGTC1' -Location 'AustraliaEast' -AddressPrefix '10.1.0.0/16' -Subnet $antsubnet -Tag $tags
$publicip = New-AzPublicIpAddress -ResourceGroupName "IN609OE1-LEGGTC1" -name "leggtc1-vn-public" -location "AustraliaEast" -AllocationMethod Static -Sku Standard
$bastion = New-AzBastion -ResourceGroupName "IN609OE1-LEGGTC1" -Name 'anthony-bastion-sn' -PublicIpAddress $publicip -VirtualNetwork $virtualNetwork -Tag $tags

$set = New-AzAvailabilitySet -ResourceGroupName IN609OE1-LEGGTC1 -Name "testset1" -Location 'Australia East'
$getset = Get-AzAvailabilitySet -ResourceGroupName IN609OE1-LEGGTC1 -Name "testset1"

$vmconfig = New-AzVMConfig -VMName "anthony-vm1" -VMSize "Standard_DS1_v2" -AvailabilitySetId $getset.Id

$vm1 = New-AzVM -ResourceGroupName IN609OE1-LEGGTC1 -Location 'Australia East' -Tag $tags -VM "Ant-VM1"

$vm1 = New-AzVm -ResourceGroupName IN609OE1-LEGGTC1 -Name "Ant-VM1" -Location "Australia East" -VirtualNetworkName "leggtc1-vn" -Credential $me


Remove-AzPublicIpAddress -Name leggtc1-vn-public -ResourceGroupName IN609OE1-LEGGTC1 -Force