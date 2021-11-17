function BackupDirectory{
    param([string]$source, [string]$destination, [string]$file, [string]$logs, [int]$timer, [int]$changes)
    robocopy $source $destination $file /b /mon:$timer /tee /fp /e /v /im /mir /log+:$logs /xf "FileModifier.jar"
}

#BackupDirectory -source "C:\Users\leggtc1\Documents\mydocs" -destination "C:\Users\leggtc1\Desktop\test" -file "*.txt" -logs "C:\Users\leggtc1\Desktop\backuplogs.txt"

BackupDirectory -source "C:\IN609" -destination "C:\Users\leggtc1\Desktop\filemodifier" -file "*" -logs "C:\Users\leggtc1\Desktop\backuplogs2.txt" -timer 1