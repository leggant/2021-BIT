# Task 1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
# set permissions
function testTime() {
    $time = (Get-Date).Hour
    if(($time -ge 18) -and ($time -lt 24)) {
        Write-Host "Evening"
    }
    elseif($time -eq 12) {
        Write-Host "Noon"
    }
    elseif($time -gt 12) {
        Write-Host "Afternoon"
    }
    else {
        Write-Host "Morning"
    }
}

testTime

# Task 2
Get-Process | ForEach-Object {(Write-Host "Process ID:" $_.Id "Process Name:" $_.Name)}

# Task 3
function getItems($path) {
"`n Get Child Items From Directory $path`n"
    foreach($item in Get-ChildItem -Path $path)
    {
        Write-Host $item.Name
    }
}

getItems C:\Users\leggtc1\

# Question 4

$nums = (1..30)
$sum = 0
$nums | ForEach-Object { $sum += $_ }
$sum

# Question 5

Get-Process | Export-Csv c:\temp\processes.csv -Delimiter ','