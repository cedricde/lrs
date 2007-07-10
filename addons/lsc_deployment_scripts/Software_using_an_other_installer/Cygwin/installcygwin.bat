@echo off

Reg QUERY "HKLM\SOFTWARE\Cygnus Solutions" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *

REM -n si l on veut pas creer de raccourci
setup.exe -q -L 
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\Cygnus Solutions" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END
