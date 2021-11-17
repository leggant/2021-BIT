$content = Get-Content -Path 'C:\Users\leggtc1\OneDrive - Otago Polytechnic\BIT_Year 2\2.OPs Eng\Checkpoint Labs\shakespeare.txt'
$stopwords = Get-Content -Path 'C:\Users\leggtc1\OneDrive - Otago Polytechnic\BIT_Year 2\2.OPs Eng\Checkpoint Labs\stopwords.txt'
$start = $content | Select-String -SimpleMatch "The Tragedy of Antony and Cleopatra" | ForEach-Object {$_.LineNumber}
$end = $content | Select-String -SimpleMatch "High order in this great solemnity." | ForEach-Object {$_.LineNumber} 
$story = $content[$start..$end] 
$words = ($story).Split(" ") | Group-Object | Sort-Object -Property Count -Descending 
$words