@echo off

REM recherche dans la BDR si le logiciel Open Workbench(st� Niku) est installe

REM reg QUERY renvoi 0 : succ�s ou 1 : echec

Reg QUERY HKLM\SOFTWARE\Niku /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
owb.1.1.4.exe /S /v/qn
echo Installation terminee.

Reg ADD HKLM\SOFTWARE\Niku /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END
