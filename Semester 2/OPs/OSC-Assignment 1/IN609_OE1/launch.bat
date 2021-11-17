:: Anthony Legg #03007276
:: init.bat
:: Script will assign get the current directory path
:: and then run the init.bat file in the current directory

:: Download and install the following packages: https://www.microsoft.com/store/productId/9N8G5RFZ9XK3

@ECHO OFF
SET DIRECTORY=%~dp0
SET ROBOPATH=%DIRECTORY%leggtc1_robocopy.ps1
TITLE 'RoboCopy Script'
:: Init the File Modifier App
Start monitor_launch.bat
PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command "%ROBOPATH%" -ArgumentList "-Scope LocalMachine"