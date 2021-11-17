function BackupDirectory{
    param([string]$source, [string]$destination, [string]$file, [string]$logs, [int]$timer, [int]$changes)
    robocopy $source $destination /b /mot:$timer /tee /e /im /is /it /x /NP /ns /mir /log+:$logs /njh /njs /copy:dat /MT:8 /w:10 /xf "FileModifier.jar"
}

BackupDirectory -source "C:\$env:HOMEPATH\Desktop\Week 5\files" -destination "C:\$env:HOMEPATH\Desktop\Week 5\backup" -file "*" -logs "C:\$env:HOMEPATH\Desktop\Week 5\backuplogs.txt" -timer 1