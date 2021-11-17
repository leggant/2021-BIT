:: Anthony Legg #03007276
:: Script will assign get the current directory path
:: and then run the init.bat file in the current directory
:: Download and install the following packages: https://www.microsoft.com/store/productId/9N8G5RFZ9XK3

@ECHO OFF
SET DIRECTORY=%~dp0
TITLE 'Monitor Script'
SET MONITOR=%DIRECTORY%leggtc1_monitor.ps1
:: Init the File Modifier App
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "%MONITOR%" -ArgumentList "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -RunAs Administrator