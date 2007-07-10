@echo off

REM recherche dans la BDR si le logiciel google toolbar est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\Google\Google Toolbar" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
google-toolbar_google_toolbar_4.0.1601_internet_explorer_francais_10208.exe /s /qn
echo Installation terminee.

Reg ADD "HKLM\SOFTWARE\Google\Google Toolbar" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END
