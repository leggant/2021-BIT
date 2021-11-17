<#
#     2021 Operations Engineering - Assignment 1
#     Anthony Legg
#     #03007276
#     Sept 1st 2021
#
#     Filename: leggtc1_monitor.ps1
#
#     Purpose: script is programmed to automatically launch when the launch.bat file 
#     is executed. This script will monitor the robocopy process which also automatically
#     launches. Robocopy monitors the 'Files' directory in the root of the 
#     project; new files/directories added here are copied to the `Backup`
#     directory. Deletions from the `File` directory are not reflected in the `Backup`.
#     Creation and deletion of files are register to the windows event log. An email is
#     sent to the user through the fakeSMTP java app. 
#>

# <#
#     Script Global Variable Declarations
# #>

$root = $PSScriptRoot
$monitor = 'monitor_launch.bat'
$smtp = 'fakeSMTP.jar'
$templog = 'templog.txt'
$tempfilepath = "$root\$templog"
$backuplog = 'backuplog.txt'
$backupfilepath = "$root\$backuplog"

# ---------------------------------------------------------------------------- #
#                           CREATE WINDOWS EVENT-LOGS                          #
# ---------------------------------------------------------------------------- #   


# ------------------------------------- X ------------------------------------ #
# -- OUTPUT ABOVE SENT TO SECOND FUNCTION TO CREATE EVENT LOG IF NOT EXISTS -- #
# ---------------- OR WRITE TO THE EVENT LOG IF IT DOES EXIST ---------------- #
# ------------------------------------- X ------------------------------------ #


# -------------------- TEST TO SEE IF AN EVENT LOG EXISTS -------------------- #

New-EventLog -LogName Application -Source $smtp -ComputerName $env:COMPUTERNAME -ErrorAction Ignore

# ---------------------------------------------------------------------------- #
#                              LAUNCH SMTP SERVER                              #
# ---------------------------------------------------------------------------- #
try {
    Start-Process -FilePath "$root\$smtp" -ArgumentList '-s -p 25 -a 127.0.0.1'
    if ($? -eq $false) {
        throw "Error: $smtp failed to start"
    }
}
catch [Exception] {
    $err = $_.Exception.Message
    Write-EventLog -LogName Application -Source $smtp -ComputerName $env:COMPUTERNAME -EntryType Error -Message "SMTP Server Error Occured $date $err" -EventID 2021 -ErrorAction Confirm
}



# ------------------------------------- X ------------------------------------ #
# ------ DO WHILE LOOP USED TO RUN ONCE PER MINUTE IN SYNC WITH ROBOCOPY ----- #
# --------- WHILE CONDITION IS DEPENDANT ON ROBOCOPY PROCESS RUNNING --------- #
# ----------------------------- IN THE BACKGROUND ---------------------------- #
# ------------------------------------- X ------------------------------------ #
                                                
do {
    $date = Get-Date -UFormat "%A, %d/%m/%Y %T"              
    Write-Host "#----------------------------------------------------------------------------------#"
    Write-Host "#---------------------------- MONITOR SCRIPT --------------------------------------#"
    Write-Host "#---------------------------- $date --------------------------------#"
    Write-Host "#----------------------------------------------------------------------------------#"
    
    $now = Get-Date
    $sourcelogtime = (Get-Item -Path $tempfilepath).LastWriteTime

    if ($sourcelogtime -gt $now.AddSeconds(-60)) {
        Write-Host "`nRoboCopy Scanned:: $now `n" -ForegroundColor Green
        Write-Host "New Changes Added To Log" -ForegroundColor Green
        $content = Get-Content -Path $tempfilepath | Select-String -Pattern "New"
        $deleted = Get-Content -Path $tempfilepath | Select-String -Pattern "Extra"
        $content = ($content -replace "\s+", " " -replace "New File", "New File Added:: " -replace "Monitor : Waiting for 1 minutes and 1 changes... ", "")
        $deleted = ($deleted -replace "\s+", " " -replace "Extra File", "File Deleted:: " -replace "Monitor : Waiting for 1 minutes and 1 changes... ", "")
        $email = @{
            To           = "something@op.ac.nz"
            From         = "leggtc1@student.nz"
            # Subject      = "Notification: $file Change Detected"
            Subject      = "Notification: Change Detected"
            Body         = "New Files: $($content | Out-String ) $($deleted | Out-String)"
            "smtpserver" = "127.0.0.1"
            Port         = "25"
        }
        Write-Host $content -ForegroundColor Green
        Write-Host $deleted -ForegroundColor Green
        Add-Content -Path $backupfilepath -Value $content
        Add-Content -Path $backupfilepath -Value $deleted
        try {
            Send-MailMessage @email
            if ($? -eq $false) {
                throw ("SMTP Server Connection Failure")
            }
        }
        catch [Exception] {
            $exception = $_.Exception.GetType().FullName
            $message = $_.Exception.Message
            Write-Host "Error:: $message" -ForegroundColor Red
            Write-EventLog -LogName Application -Source "$monitor" -ComputerName $env:COMPUTERNAME -EntryType Error -Message "Error:: $message`n$exception" -EventID 2020
        }
    }
    else {
        Write-Host "No New Changes :: Last Change Occured: $date" -ForegroundColor Green
        Write-EventLog -LogName Application -Source "$monitor" -ComputerName $env:COMPUTERNAME -EntryType Error -Message "Monitor : $sourcelogtime" -EventID 1980 -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 60
    Clear-Host
} while ($true)