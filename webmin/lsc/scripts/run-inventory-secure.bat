REM 
REM Run the inventory agent (OCS NG) using the SSH tunnel to send the inventory
REM 
:V4
"C:\Program Files\OCS Inventory NG\ocsinventory.exe" /server:127.0.0.1 /pnum:30080 /np /debug

:END
