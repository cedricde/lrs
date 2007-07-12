@echo off

REM recherche dans la BDR si le logiciel Psi est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\psi" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"psi-0.9.3-win-setup.exe" /S 

REM pour creer un raccourci on se sert de l executable Shortcut 

REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\psi.lnk" /a:c /t:"C:\Program Files\Psi\psi.exe" 
 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\uninstall.lnk" /a:c /t:"C:\Program Files\Psi\uninstall.exe" 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\Psi - Documentation.lnk" /a:c /t:"C:\Program Files\Psi\Psi - Documentation.url" 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\Psi - Forum.lnk" /a:c /t:"C:\Program Files\Psi\Psi - Forum.url"

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\Psi - Home page.lnk" /a:c /t:"C:\Program Files\Psi\Psi - Home page.url"

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\Readme.lnk" /a:c /t:"C:\Program Files\Psi\Readme.txt" 

cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir Psi
chmod ugo+rwx Psi
cd Psi
cp  "C:\Documents and Settings\All Users\Bureau\psi.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\uninstall.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\Psi - Documentation.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\Psi - Forum.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\Psi - Home page.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\Readme.lnk" .

cd "C:\Documents and Settings\All Users\Bureau\"
del uninstall.lnk /q
cd "C:\Documents and Settings\All Users\Bureau\"
del "Psi - Documentation.lnk" /q
cd "C:\Documents and Settings\All Users\Bureau\"
del "Psi - Forum.lnk" /q
cd "C:\Documents and Settings\All Users\Bureau\"
del "Psi - Home page.lnk" /q
cd "C:\Documents and Settings\All Users\Bureau\"
del Readme.lnk /q
cd \

echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\psi" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END