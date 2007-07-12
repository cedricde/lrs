@echo off

Reg QUERY "HKLM\SOFTWARE\pdf spit and merge" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
pdfsam-win32inst-v0_6_sr3.exe /S

REM pour creer un raccourci on se sert de l executable Shortcut 

REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\pdfsam-starter.lnk" /a:c /t:"C:\Program Files\pdfsam\pdfsam-starter.exe" 
 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\pdfsam-0.6sr3.lnk" /a:c /t:"C:\Program Files\pdfsam\pdfsam-0.6sr3.jar"

cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir "PDF Split And Merge" 
chmod ugo+rwx "PDF Split And Merge"
cd "PDF Split And Merge"
cp  "C:\Documents and Settings\All Users\Bureau\pdfsam-starter.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\pdfsam-0.6sr3.lnk" .

cd \

echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\pdf spit and merge" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END
