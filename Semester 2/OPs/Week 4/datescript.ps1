function datestring  {
    param([string]$day,  [string]$month, [string]$year)
    $newDate = Get-Date -Date "$day-$month-$year" -UFormat "%A, %d/%m/%Y"
    Write-Host "Date is: $newDate"
}
datestring -day "1" -month "8" -year "2021"
