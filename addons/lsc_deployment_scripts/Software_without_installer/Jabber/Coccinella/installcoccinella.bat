@echo off

REM recherche dans la BDR si le logiciel Coccinella est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY HKLM\SOFTWARE\coccinella /v Flag >nul
goto %ERRORLEVEL%

:1

echo Debut de l'installation

REM le logiciel Coccinella n'a pas d'installateur donc on le copie directement dans program files et on place les executables sur le bureau et dans "démarrer" pour tous les utilisateurs

cd \
REM fais une copie dans le repertoire program files
cd C:\Program Files\
cp -r C:\lsc\Coccinella .
chmod ugo+rwx "C:\Program Files\Coccinella" 
cd "C:\Program Files\Coccinella"
chmod ugo+rwx *
cd \


cd C:\lsc

REM pour creer un raccourci on se sert de l executable Shortcut 


REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\Coccinella-0.95.16.lnk" /a:c /t:"C:\Program Files\Coccinella\Coccinella-0.95.16.exe" 

cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir Coccinella
chmod ugo+rwx Coccinella
cd Coccinella
cp  "C:\Documents and Settings\All Users\Bureau\Coccinella-0.95.16.lnk" .

cd \

REM création d'un flag dans la BDR ainsi qu'une clé
reg add HKLM\SOFTWARE\coccinella /v Flag /t REG_DWORD /d "1" /f 

echo Installation terminee.
goto END

:0

echo logiciel deja installe
exit 1

:END
