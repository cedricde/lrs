@echo off

REM recherche dans la BDR si le logiciel Wengophone est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\WengoPhone" /v Flag >nul
goto %ERRORLEVEL%

:1

cd 

echo Debut de l'installation
chmod ugo+rx *
"WengoPhone-2.0-beta1-windows.exe" /S 

REM pour creer un raccourci on se sert de l executable Shortcut 

REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\qtwengophone.lnk" /a:c /t:"C:\Program Files\WengoPhone\qtwengophone.exe" 
 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\uninstall.lnk" /a:c /t:"C:\Program Files\WengoPhone\uninstall.exe" 
cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir WengoPhone
chmod ugo+rwx WengoPhone
cd WengoPhone
cp  "C:\Documents and Settings\All Users\Bureau\qtwengophone.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\uninstall.lnk" .

cd "C:\Documents and Settings\All Users\Bureau\"
del uninstall.lnk /q
cd \

echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\WengoPhone" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END