@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\Firebird Project" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Firebird 2.0 n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\Firebird\Firebird_2_0"
"unins000.exe" /sp- /verysilent /norestart
cd\
chmod ugo+rwx "C:\Program Files\Firebird\Firebird_2_0"
cd \
rmdir "\Program Files\Firebird" /s /q
echo Desinstallation terminee


:end