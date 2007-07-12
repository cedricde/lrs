@echo off

REM recherche dans la BDR si le logiciel batik-1.7 est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY HKLM\SOFTWARE\batik-1.7 /v Flag >nul
goto %ERRORLEVEL%

:1

echo Debut de l'installation

REM le logiciel batik-1.7 n'a pas d'installateur donc on le copie directement dans program files et on place les executables sur le bureau et dans "démarrer" pour tous les utilisateurs

cd \
REM fais une copie dans le repertoire program files
cd C:\Program Files\
cp -r C:\lsc\batik-1.7 .
chmod ugo+rwx "C:\Program Files\batik-1.7" 
cd "C:\Program Files\batik-1.7"
chmod ugo+rwx *
cd \


cd C:\lsc

REM pour creer un raccourci on se sert de l executable Shortcut 


REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\batik.lnk" /a:c /t:"C:\Program Files\batik-1.7\batik.jar" 

cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir batik-1.7
chmod ugo+rwx batik-1.7
cd batik-1.7
cp  "C:\Documents and Settings\All Users\Bureau\batik.lnk" .

cd \

REM création d'un flag dans la BDR ainsi qu'une clé
reg add HKLM\SOFTWARE\batik-1.7 /v Flag /t REG_DWORD /d "1" /f 

echo Installation terminee.
goto END

:0

echo logiciel deja installe
exit 1

:END
