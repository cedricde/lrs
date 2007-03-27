cmd /C C:\lsc\setupssh.exe /S
ping -n 1 -w 10000 1.1.1.1 >NUL
del /S /Q C:\lsc
