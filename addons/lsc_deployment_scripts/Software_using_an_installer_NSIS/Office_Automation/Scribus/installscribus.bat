@echo off

REM recherche dans la BDR si le logiciel Scribus est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Scribus 1.3.3" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"scribus-1.3.3.9-win32-install.exe" /S 

REM pour creer un raccourci on se sert de l executable Shortcut 

REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\Scribus.lnk" /a:c /t:"C:\Program Files\Scribus 1.3.3.9\Scribus.exe" 
 
cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir Scribus
chmod ugo+rwx Scribus
cd Scribus
cp  "C:\Documents and Settings\All Users\Bureau\Scribus.lnk" .

cd \

echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Scribus 1.3.3" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END