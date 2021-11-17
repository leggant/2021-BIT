function get-myfiles {
    param([string]$filetypes, [int]$month, [int]$year, [string]$path)
    Get-ChildItem -Path $path -File $filetypes | Where-Object {$_.CreationTime -gt [DateTime]"$year-$month-01"}
}
get-myfiles -filetypes *.pdf -month 1 -year 2020 -path C:\Users\leggtc1\Desktop\


<#
7.	Write a function named get-myfiles which will take parameters like the following and show the desired output:
Param (
[string[]] $fileTypes,
[int] $month,
[int] $year,
[string[]]  $path
, [int]$year, [string]$path
)
#>