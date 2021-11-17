New-Item -Path D:\ -ItemType Directory -Name "temp"

function createFile {
    param([string]$name, [string]$path)
    New-Item -Path $path -ItemType File -Name $name
}

createFile -name "theWall.txt" -path D:\temp

for($count = 1; $count -le 20; $count++)
{
    $file = "file" + "$count" + ".txt"
    New-Item -Path D:\temp -Name $file
}

$files = Get-ChildItem -Path D:\temp
foreach($x in $files){ Remove-Item  D:\temp\$x }

$path = 'C:\Users\leggtc1\OneDrive - Otago Polytechnic\BIT_Year 2\2.OPs Eng\Week 3\phonebook.txt'
$homepathfile = 'C:\Users\Ant\OneDrive - Otago Polytechnic\BIT_Year 2\2.OPs Eng\Week 3\phonebook.txt'
$mytext = (Get-Content $homepathfile)

# Or

$mytext = Get-Content -Path $path
$mytext[0..2]

# Q6

New-Item -Path 'C:\Users\leggtc1\OneDrive - Otago Polytechnic\BIT_Year 2\2.OPs Eng\Week 3' -ItemType File -Name "onlyphones.txt"
$mytext | Select-String -Pattern "\(...\) ...-...." > "C:\Users\leggtc1\OneDrive - Otago Polytechnic\BIT_Year 2\2.OPs Eng\Week 3\onlyphones.txt"

# Q7 
# Open the file phonebook.txt and replace the string “coporal kennedy” with “sunny florida”
# Hints: save the file on a variable and then use replace operator.
$search = “coporal kennedy”
$update = "sunny florida"
(Get-Content -Path $path) -replace $search,$update | Set-Content -Path $path 
Get-Content -Path $path

# (Select-String -Path $path -SimpleMatch $search) | {($_)}


# Q8
$words = (Get-Content -Path $homepathfile) | ForEach-Object {$_.Split(" ") -match '[A-Z][a-z]'} | Group-Object | Sort-Object | Select-Object Name, Count 
$words
$words = (Get-Content -Path $path) | ForEach-Object {$_.Split(" ") -match '[A-Z][a-z]'} | Group-Object | Sort-Object | Select-Object Name, Count 
$words