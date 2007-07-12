@echo off

REM recherche dans la BDR si le logiciel Miranda est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\miranda" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"miranda-im-v0.6.8-unicode.exe" /S 
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\miranda" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END