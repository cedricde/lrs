@echo off

REM recherche dans la BDR si le logiciel Abiword est installe

REM reg QUERY renvoi 0 : succ�s ou 1 : echec

Reg QUERY HKLM\SOFTWARE\AbiSuite /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"abiword-setup-2.4.6.exe" /S 
echo Installation terminee.


Reg ADD HKLM\SOFTWARE\AbiSuite /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END