@echo off


Reg QUERY HKLM\SOFTWARE\imagej /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
ij137-nojre-setup.exe /verysilent /norestart
echo Installation terminee.


Reg ADD HKLM\SOFTWARE\imagej /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END