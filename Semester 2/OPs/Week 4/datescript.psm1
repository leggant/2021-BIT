function datestring  {
    param([string]$day,  [string]$month, [string]$year)
    $newDate = Get-Date -Date "$day-$month-$year" -UFormat "%A, %d/%m/%Y"
    Write-Host "Date is: $newDate"
}

<#
to call this create directory of same name in the 
`C:\Program Files\WindowsPowerShell\Modules` directory
`C:\Program Files\WindowsPowerShell\Modules\datestring`
copy the psm1 file inside this new folder
Import-Module datestring
then in the command line run `datestring -day "1" -month "8" -year "2021"`
#>