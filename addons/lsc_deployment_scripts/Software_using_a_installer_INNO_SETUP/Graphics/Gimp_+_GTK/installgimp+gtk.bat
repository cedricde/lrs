@echo off

REM recherche dans la BDR si le l environnement GTK + est installe et ensuite si le logiciel est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY HKLM\SOFTWARE\GTK /v Flag >nul
goto %ERRORLEVEL%

:1


REM installation de l environnement GTK est necessaire pour que le logiciel GIMP fonctionne 

echo Debut de l'installation
chmod ugo+rx *
gtk+-2.10.11-setup.exe /sp- /verysilent /norestart
echo Installation terminee.



Reg QUERY HKLM\SOFTWARE\gimp /v Flag >nul
goto %ERRORLEVEL%

:1

REM puis installation de GIMP
echo Debut de l'installation
chmod ugo+rx *
gimp-2.2.15-i586-setup-1.exe /sp- /verysilent /norestart
echo Installation terminee.

Reg ADD HKLM\SOFTWARE\GTK /v Flag /t REG_DWORD /d "1" /f
Reg ADD HKLM\SOFTWARE\gimp /v Flag /t REG_DWORD /d "1" /f
goto END



:0

echo environnement GTK deja installe

Reg QUERY HKLM\SOFTWARE\gimp /v Flag >nul
goto %ERRORLEVEL%

:1

REM puis installation de GIMP
echo Debut de l'installation
chmod ugo+rx *
gimp-2.2.15-i586-setup-1.exe /sp- /verysilent /norestart
echo Installation terminee.

Reg ADD HKLM\SOFTWARE\gimp /v Flag /t REG_DWORD /d "1" /f
goto END

:0

logiciel Gimp deja installe 
exit 1

:END
