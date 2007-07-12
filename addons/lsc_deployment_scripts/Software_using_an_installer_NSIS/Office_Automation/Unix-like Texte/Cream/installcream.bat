@echo off


Reg QUERY "HKLM\SOFTWARE\cream" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
cream-0-39-gvim-7-1-2.exe /S 

REM a travers le LRS l installation silencieuse ne cree pas de raccourci, donc on n en cree dans le menu Demarrer et sur le bureau 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\gvim.lnk" /a:c /t:"C:\Program Files\vim\vim71\gvim.exe" 

 
cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir "Vim7.1"
chmod ugo+rwx "Vim7.1"
cd "Vim7.1"
cp  "C:\Documents and Settings\All Users\Bureau\gvim.lnk" .

cd \

echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\cream" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END