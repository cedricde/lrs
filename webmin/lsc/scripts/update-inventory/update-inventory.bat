REM LRS Inventory. Update to the agent v4.x

"C:\Program Files\LRS Inventory Agent"\unins000.exe /silent
"C:\Program Files\LRS Inventory Agent"\unins001.exe /silent
chmod.exe +x inventory-setup.exe
inventory-setup.exe  /sp- /silent /norestart /lrsserver=LRS
