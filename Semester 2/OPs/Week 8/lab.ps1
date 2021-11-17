function connectAZ {
    Param(
        [string]$tenant,
        [string]$subscription
    )
    $connection = Connect-AzAccount -Tenant $tenant -Subscription $subscription `
    | ForEach-Object {Write-Host Connection to Azure Successful: `
    $_.Context.Account Subscription: $_.Context.Subscription Tenant: $_.Context.Tenant `
     -ForegroundColor Green -BackgroundColor Black} 
}
connectAZ -tenant 450e6824-88ab-4ad2-914d-b0f385da600c -subscription ee67cd86-3ab6-4382-81f9-9e62f569ffc6

#$tags = @{}
#$tags.Add('leggtc1','c82')
#$set = New-AzAvailabilitySet -ResourceGroupName IN609OE1-LEGGTC1 -Name "testset1" -Location 'Australia East'
#$getset = Get-AzAvailabilitySet -ResourceGroupName IN609OE1-LEGGTC1 -Name "testset1"
#$vm1 = New-AzVm -ResourceGroupName IN609OE1-LEGGTC1 -Name "Anthony-c82" -Location "Australia East" -Credential $me -Image Win2016Datacenter