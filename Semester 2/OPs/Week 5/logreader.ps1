function Read{
    param([string]$source)
    $content = Get-Content $source
    Get-Content $source | Where-Object {$_ -like "*EXTRA File*"} | ForEach-Object {
        $newline = $_ -creplace "\*EXTRA", "DELETED" -replace "\s+", "" -creplace "File", " "
        $newline | Out-File -FilePath C:\$env:HOMEPATH\Desktop\backuplogs.txt -Append
        Write-Host $newline
    }

    Get-Content $source | Where-Object {$_ -like "*New File*"} | ForEach-Object {
        $newline = $_ -replace "New File", "CREATED" -creplace "\s+", " "
        $path = $newline -split "\files"

        $newline | Out-File -FilePath C:\$env:HOMEPATH\Desktop\backuplogs.txt -Append
        Write-Host $newline $path
    }
}

Read "C:\$env:HOMEPATH\Desktop\Week 5\backuplogs.txt"