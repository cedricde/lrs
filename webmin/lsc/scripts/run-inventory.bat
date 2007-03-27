REM 
REM Run the inventory agent (OCSv2/v3/v4 NG)
REM 
IF EXIST "C:\Program Files\OCS Inventory NG\ocsinventory.exe" GOTO V4
DEL "C:\Program Files\LRS Inventory Agent\ocs\Hardware\*.csv"
"C:\Program Files\LRS Inventory Agent\lrs-inventory.exe"
GOTO END

:V4
REM get the IP address
FOR /F "tokens=1" %%i in ("%SSH_CLIENT%") do set IP=%%i
@echo IP: %IP%
"C:\Program Files\OCS Inventory NG\ocsinventory.exe" /server:%IP% /debug

:END
