@echo off

REM on supprime le repertoire cliparts18 place dans le repertoire share\gallery d OOo


Reg delete HKLM\SOFTWARE\OpenOffice.org /v Flag2 /f 
goto %ERRORLEVEL%

:1

echo Le le repertoire cliparts18 n est pas installe dans le repertoire share\gallery d OOo
exit 1
GOTO end


:0

REM on supprime le repertoire cliparts18 place dans le repertoire share\gallery d OOo
echo debut de la suppression
cd \
cd "C:\Program Files\OpenOffice.org*\share\gallery"

rmdir cliparts018 /s /q 

echo Desinstallation terminee


:end