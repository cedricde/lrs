@echo off


Reg QUERY HKLM\SOFTWARE\tail /v Flag >nul
goto %ERRORLEVEL%

:1

echo Debut de l'installation

REM le logiciel tail 4.2.12 n'a pas d'installateur donc on le copie directement dans program files et on place les executables sur le bureau et dans "démarrer" pour tous les utilisateurs

cd \
REM fais une copie dans le repertoire program files
cd C:\Program Files\
cp -r "C:\lsc\Tail 4.2.12" .
chmod ugo+rwx "C:\Program Files\Tail 4.2.12" 
cd "C:\Program Files\Tail 4.2.12"
chmod ugo+rwx *
cd \


cd C:\lsc

REM pour creer un raccourci on se sert de l executable Shortcut 


REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\Tail.lnk" /a:c /t:"C:\Program Files\Tail 4.2.12\Tail.exe" 

cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir "Tail 4.2.12"
chmod ugo+rwx "Tail 4.2.12"
cd "Tail 4.2.12"
cp  "C:\Documents and Settings\All Users\Bureau\Tail.lnk" .

cd \

REM création d'un flag dans la BDR ainsi qu'une clé
reg add HKLM\SOFTWARE\tail /v Flag /t REG_DWORD /d "1" /f 

echo Installation terminee.
goto END

:0

echo logiciel deja installe
exit 1

:END