<#
    2021 Operations Engineering - Assignment 1
    Anthony Legg
    #03007276
    Sept 1st 2021

    Submitted Sept 6th 2021

    filename: leggtc1_robocopy.ps1
    Purpose: 
        This script is launched by the `launch.sh` script.
        It runs the robocopy command, this process copys files from the `./Files`
        source directory to the destination directory `./Backup` folder. 
        The robocopy process, continues to run This process continually checks the source
        folder, if changes, new or deleted files are detected, a log is generated 
        of these changes and a copy of the files is made. 
        
        The script also creates a new windows event log for robocopy,

#>

<#
    Script Global Variable Declarations
#>

$root = $PSScriptRoot
$source = "$root\Files"
$destination = "$root\Backup"
$modifier = "$root\Files\FileModifier.jar"
$logfile = "$root\templog.txt"
$file = "leggtc1_robocopy.ps1"

function testRoboLog {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$name
    )
    [System.Diagnostics.EventLog]::SourceExists($name)
}

# ---------------------------------------------------------------------------- #
#                           CREATE WINDOWS EVENT-LOG                           #
# ---------------------------------------------------------------------------- #

$res = testRoboLog -name "$file"

if ($res -eq $False) {
    New-EventLog -LogName Application -Source $file -ComputerName $env:COMPUTERNAME
    Write-EventLog -LogName Application -Source $file -ComputerName $env:COMPUTERNAME -EntryType Information -Message "Windows Event Log:: $file Created" -EventID 1980
}
else {
    Write-EventLog -LogName Application -Source $file -ComputerName $env:COMPUTERNAME `
        -EntryType Information -Message "Checked For Event Log:: $file Confirms, Already Exists" `
        -EventID 2021
}

# Formats the date string as `Monday, 01/12/2021 13:01:00`
$date = Get-Date -UFormat "%A, %d/%m/%Y %T"

Write-Host "#---------------------------------------------------------------------------------#" -ForegroundColor Green
Write-Host "#ROBOCOPY SCRIPT LOADED-----------------------------------------------------------#" -ForegroundColor Green
Write-Host "#$date-----------------------------------------------------#" -ForegroundColor Green
Write-Host "#---------------------------------------------------------------------------------#" -ForegroundColor Green

<#
    ROBOCOPY Flags Used:
    /mot:<n> Monitors the source, and runs again in n minutes, if changes are detected.
    /b Copies files in backup mode. Backup mode allows Robocopy to override file and folder permission settings (ACLs). 
    /tee Writes the status output to the console window, as well as to the log file.
    /s Copies subdirectories. Automatically excludes empty directories.
    /z Copies files in restartable mode. Should a file copy be interrupted,
       Robocopy can pick up where it left off.
    /xo	Excludes older files.
    /ns	Specifies that file sizes are not to be logged.
    /np	Specifies that the progress of the copying operation.
    /njh Specifies that there is no job header.
    /njs Specifies that there is no job summary.
    /xf <filename>[ ...] Specifies that the specified files are to be excluded from the copy.
    /mot:<m> Monitors the source, and runs again in m minutes, if changes are detected.
#>

try {
    Set-Location $source
    Start-Process $modifier -ArgumentList $modifier
    Set-Location $root
    robocopy $source $destination /log:$logfile /e /np /ndl /ns /njs /njh /tee /xo /mot:1 /xn /xf $modifier
}
catch {
    $message = $_.Exception.Message
    Write-EventLog -LogName Application -Source $file -ComputerName $env:COMPUTERNAME `
        -EntryType Error -Message "Robocopy Script Failed. Error:: $message" -EventID 2020
    Write-Host "Robocopy Script Failed. Error:: $message" -ForegroundColor Red
    Stop-Process -Name robocopy
}