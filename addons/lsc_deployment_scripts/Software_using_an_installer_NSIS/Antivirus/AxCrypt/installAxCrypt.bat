@echo off

REM recherche dans la BDR si le logiciel AxCrypt est installe

Reg QUERY "HKLM\SOFTWARE\Axon Data" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
AxCrypt-Setup.exe /S 
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\Axon Data" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END
