@echo off

REM recherche dans la BDR si le logiciel ganttproject est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\GanttProject" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"ganttproject-2.0.4.exe" /S 

REM pour creer un raccourci on se sert de l executable Shortcut 

REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\ganttproject.lnk" /a:c /t:"C:\Program Files\GanttProject\ganttproject.exe" 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\uninstall.lnk" /a:c /t:"C:\Program Files\GanttProject\uninstall.exe" 
 
cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir GanttProject
chmod ugo+rwx GanttProject
cd GanttProject
cp  "C:\Documents and Settings\All Users\Bureau\ganttproject.lnk" .

cp  "C:\Documents and Settings\All Users\Bureau\uninstall.lnk" .
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del uninstall.lnk /q
cd \

echo Installation terminee.

Reg ADD "HKLM\SOFTWARE\GanttProject" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END