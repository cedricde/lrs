@echo off

REM recherche dans la BDR si le logiciel Thunderbird version 2.0.0.0 est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\Mozilla\Mozilla Thunderbird 2.0.0.0" 
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"Thunderbird Setup 2.0.0.0.exe" /S 
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\Mozilla\Mozilla Thunderbird 2.0.0.0" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END