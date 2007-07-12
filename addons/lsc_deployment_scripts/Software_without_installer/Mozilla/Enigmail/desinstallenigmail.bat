@echo off

REM on supprime l extension enigmail place dans le repertoire Program Files\Mozilla Firefox\extensions et ou Program Files\Mozilla Thunderbird\extensions


Reg delete HKLM\SOFTWARE\Mozilla /v Flag2 /f 
goto %ERRORLEVEL%

:1

echo L extension enigmail n est pas installe 
exit 1
GOTO end


:0

REM on supprime l extension enigmail place dans le repertoire Program Files\Mozilla Firefox\extensions et ou Program Files\Mozilla Thunderbird\extensions
echo debut de la suppression
cd \
cd "C:\Program Files\Mozilla Firefox\extensions"
rmdir enigmail-0.95.1-tb+sm.xpi /s /q 

cd \ 
cd "C:\Program Files\Mozilla Thunderbird\extensions"
rmdir enigmail-0.95.1-tb+sm.xpi /s /q
cd \

echo Desinstallation terminee


:end