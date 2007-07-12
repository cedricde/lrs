@echo off

REM recherche dans la BDR si le logiciel Grisbi est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GRISBI" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"grisbi-0.5.9-win32-gcc-gtk-2.6.9-060725-full.exe" /S 
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GRISBI" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END