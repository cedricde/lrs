@echo off

Reg QUERY HKLM\SOFTWARE\imageMagick /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
ImageMagick-6.3.4-8-Q16-windows-dll.exe /sp- /verysilent /norestart
echo Installation terminee.


Reg ADD HKLM\SOFTWARE\imageMagick /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END