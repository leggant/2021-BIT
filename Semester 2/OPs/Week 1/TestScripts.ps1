Get-Process | where {$_.WorkingSet -lt 5mb} | sort workingset
Get-Process | where {$_.WorkingSet -gt 5mb -and $_.ProcessName.StartsWith("S*")}