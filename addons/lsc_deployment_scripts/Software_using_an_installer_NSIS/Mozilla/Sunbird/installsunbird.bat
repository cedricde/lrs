@echo off

REM recherche dans la BDR si le logiciel Sunbird est installe

REM reg QUERY renvoi 0 : succ�s ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\Mozilla\Mozilla Sunbird 0.3.1" 
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"sunbird-0.3.1.en-US.win32.installer.exe" /S 
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\Mozilla\Mozilla Sunbird 0.3.1" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END