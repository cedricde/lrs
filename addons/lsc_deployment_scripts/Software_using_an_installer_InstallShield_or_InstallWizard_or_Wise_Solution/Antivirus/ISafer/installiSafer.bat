@echo off

REM recherche dans la BDR si le logiciel iSafer est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY HKLM\SOFTWARE\iSafer /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
iSafer-3.0.0.1-setup.exe /S
taskkill /im iSafer.exe /f
taskkill /im iSaferSvr.exe /f
taskkill /im iSafer-3.0.0.1-setup.exe /f

echo Installation terminee.


Reg ADD HKLM\SOFTWARE\iSafer /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END
