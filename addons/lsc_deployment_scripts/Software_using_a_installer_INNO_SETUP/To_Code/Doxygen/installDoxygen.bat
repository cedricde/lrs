@echo off

REM recherche dans la BDR si le logiciel doxygen est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY HKLM\SOFTWARE\doxygen /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"doxygen-1.5.2-setup.exe" /sp- /verysilent /norestart 
echo Installation terminee.


Reg ADD HKLM\SOFTWARE\doxygen /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1
:END