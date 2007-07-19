@echo off


Reg QUERY "HKLM\SOFTWARE\TortoiseSVN" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
msiexec /i TortoiseSVN-1.4.4.9706-win32-svn-1.4.4.msi /qn /norestart
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\TortoiseSVN" /v Flag /t REG_DWORD /d "1" /f 
goto END

:0

echo logiciel deja installe
exit 1

:END