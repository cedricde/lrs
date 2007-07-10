@echo off

REM recherche dans la BDR si le logiciel OpenOffice est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY HKLM\SOFTWARE\OpenOffice.org /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
msiexec.exe /i openofficeorg22.msi /qn /lv OOo2.log.txt /norestart
echo Installation terminee.
type OOo2.log.txt
rm -f OOo2.log.txt

Reg ADD HKLM\SOFTWARE\OpenOffice.org /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END
