@echo off

Reg QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GeoShell R4" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"GeoShell_R4.11.10_Setup.exe" /S /D=C:\Program Files\Shell
echo Installation terminee.

cd C:\lsc

REM cet installateur ne cree pas de raccourci


REM on fais un raccourci de l executable sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\GeoShell.lnk" /a:c /t:"C:\Program Files\Shell\GeoShell.exe" 

cd \

REM on fais un raccourci de l executable dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir GeoShell
chmod ugo+rwx GeoShell
cd GeoShell
cp  "C:\Documents and Settings\All Users\Bureau\GeoShell.lnk" .

cd \


Reg ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GeoShell R4" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END