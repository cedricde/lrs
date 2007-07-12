@echo off

REM recherche dans la BDR si le logiciel gnumeric est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\gnumeric" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"gnumeric-1.6.3-win32-2.exe" /S /D=C:\Program Files\Gnumeric
echo Installation terminee.

REM pour creer un raccourci on se sert de l executable Shortcut 

REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\gnumeric.lnk" /a:c /t:"C:\Program Files\Gnumeric\bin\gnumeric.exe" 
 
cd \

REM Gnumeric cree 4 raccourcis mais ils ne sont pas places dans un repertoire, en plus ils sont installes dans la session locale, donc on les copie dans un repertoire dans le menu Demarrer de tous les utilisateurs du poste 


REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir Gnumeric
chmod ugo+rwx Gnumeric
cd \

FOR /r "C:\Documents and Settings" %%i In ("Gnumeric Spreadsheet.*","Gnumeric Spreadsheet Help.*","Theme Selector.*") Do move /Y "%%~i" C:\DOCUME~1\ALLUSE~1\MENUDM~1\PROGRA~1\Gnumeric
 


Reg ADD "HKLM\SOFTWARE\gnumeric" /v Flag /t REG_DWORD /d "1" /f



goto END

:0

echo logiciel deja installe
exit 1

:END