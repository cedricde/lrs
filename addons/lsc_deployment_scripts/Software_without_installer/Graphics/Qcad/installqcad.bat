@echo off


Reg QUERY HKLM\SOFTWARE\qcad /v Flag >nul
goto %ERRORLEVEL%

:1

echo Debut de l'installation

REM le logiciel qcad a un installateur mais cet installateur n a pas de parametres silencieux donc on le copie directement dans program files et on place les executables sur le bureau et dans "démarrer" pour tous les utilisateurs

cd \
REM fais une copie dans le repertoire program files
cd C:\Program Files\
cp -r "C:\lsc\QCad" .
chmod ugo+rwx "C:\Program Files\QCad" 
cd "C:\Program Files\QCad"
chmod ugo+rwx *
cd \


cd C:\lsc

REM pour creer un raccourci on se sert de l executable Shortcut 


REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\qcad.lnk" /a:c /t:"C:\Program Files\QCad\qcad.exe" 

cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir "QCad"
chmod ugo+rwx "QCad"
cd "QCad"
cp  "C:\Documents and Settings\All Users\Bureau\qcad.lnk" .

cd \

REM création d'un flag dans la BDR ainsi qu'une clé
reg add HKLM\SOFTWARE\qcad /v Flag /t REG_DWORD /d "1" /f 

echo Installation terminee.
goto END

:0

echo logiciel deja installe
exit 1

:END