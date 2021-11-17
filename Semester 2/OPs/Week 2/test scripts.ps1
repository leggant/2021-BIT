# Read File Content

#$content = Get-Content c:\temp\processes.csv
#$content = ${c:\temp\processes.csv}

# Search text content
#Select-String -Simple Thread c:\temp\processes.csv

$records = Get-Content 'C:\Users\leggtc1\OneDrive - Otago Polytechnic\BIT_Year 2\2.OPs Eng\Week 2\phone.txt' -Delimiter "----"
$parseExpression = "(?s)Name: (\S*).*Phone: (\S*).*"
