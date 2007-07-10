@echo off


REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\Python" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Python n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
C:\WINDOWS\system32\msiexec.exe /x{31800004-6386-4999-a519-518f2d78d8f0} /qn /norestart
echo Desinstallation terminee


:end


