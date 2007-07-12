@echo off


Reg QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Abakt.exe" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
abakt-0.9.5.exe /S
echo Installation terminee.

cd \
cd lsc 
REM pour creer un raccourci on se sert de l executable Shortcut 

REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\Abakt.lnk" /a:c /t:"C:\Program Files\Abakt\Abakt.exe" 
 
cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir Abakt
chmod ugo+rwx Abakt
cd Abakt
cp  "C:\Documents and Settings\All Users\Bureau\Abakt.lnk" .

cd \

Reg ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Abakt.exe" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END
