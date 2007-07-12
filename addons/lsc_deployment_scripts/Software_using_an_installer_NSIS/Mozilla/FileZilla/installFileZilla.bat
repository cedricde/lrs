@echo off

Reg QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FileZilla" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"FileZilla_2_2_32_setup.exe" /S 

REM pour creer un raccourci on se sert de l executable Shortcut 

REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\FileZilla.lnk" /a:c /t:"C:\Program Files\FileZilla\FileZilla.exe" 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\uninstall.lnk" /a:c /t:"C:\Program Files\FileZilla\uninstall.exe" 
 
cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir FileZilla
chmod ugo+rwx FileZilla
cd FileZilla
cp  "C:\Documents and Settings\All Users\Bureau\FileZilla.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\uninstall.lnk" .

cd\
cd "C:\Documents and Settings\All Users\Bureau"
del uninstall.lnk /q
cd \

echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FileZilla" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END