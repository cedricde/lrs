@echo off

REM recherche dans la BDR si le logiciel SmartEiffel est installe

Reg QUERY HKLM\SOFTWARE\SmartEiffel /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
SmartEiffel-2-2.exe /S /D=C:\Program Files\SmartEiffel
echo Installation terminee.


Reg ADD HKLM\SOFTWARE\SmartEiffel /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END
