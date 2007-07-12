@echo off


Reg QUERY HKLM\SOFTWARE\7-Zip /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
7z442.exe /S
echo Installation terminee.


Reg ADD HKLM\SOFTWARE\7-Zip /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END
