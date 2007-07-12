@echo off

REM recherche dans la BDR si le logiciel jPodder est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\jPodder" /v Flag >nul
goto %ERRORLEVEL%

:1

cd 

echo Debut de l'installation
chmod ugo+rx *
"jPodder-Setup.exe" /S 

REM pour creer un raccourci on se sert de l executable Shortcut 

REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\jpodder.lnk" /a:c /t:"C:\Program Files\jPodder\bin\jpodder.cmd"
 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\jPodder site.lnk" /a:c /t:"C:\Program Files\jPodder\jPodder.url" 


Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\Uninstall.lnk" /a:c /t:"C:\Program Files\jPodder\uninst.exe" 
cd \


REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir jPodder
chmod ugo+rwx jPodder
cd jPodder
cp  "C:\Documents and Settings\All Users\Bureau\jPodder.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\jPodder site.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\Uninstall.lnk" .

cd "C:\Documents and Settings\All Users\Bureau\"
del Uninstall.lnk /q
del "jPodder site.lnk" /q
cd \

echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\jPodder" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END