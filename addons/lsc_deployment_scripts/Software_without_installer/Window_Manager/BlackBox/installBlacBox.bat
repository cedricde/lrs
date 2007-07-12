@echo off

REM recherche dans la BDR si le logiciel BlackBox est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY HKLM\SOFTWARE\BlackBox /v Flag >nul
goto %ERRORLEVEL%

:1

echo Debut de l'installation

REM le logiciel BlackBox n'a pas d'installateur donc on le copie directement dans program files et on place les executables sur le bureau et dans "démarrer" pour tous les utilisateurs

cd \
REM fais une copie dans le repertoire program files
cd C:\Program Files\
cp -r "C:\lsc\BlackBox 4 Win 0.0.92" .
chmod ugo+rwx "C:\Program Files\BlackBox 4 Win 0.0.92" 
cd "C:\Program Files\BlackBox 4 Win 0.0.92"
chmod ugo+rwx *
cd \


cd C:\lsc

REM pour creer un raccourci on se sert de l executable Shortcut 


REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\Blackbox.lnk" /a:c /t:"C:\Program Files\BlackBox 4 Win 0.0.92\Blackbox\Blackbox.exe" 

cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir BlackBox
chmod ugo+rwx BlackBox
cd BlackBox
cp  "C:\Documents and Settings\All Users\Bureau\Blackbox.lnk" .

cd \

REM création d'un flag dans la BDR ainsi qu'une clé
reg add HKLM\SOFTWARE\BlackBox /v Flag /t REG_DWORD /d "1" /f 

echo Installation terminee.
goto END

:0

echo logiciel deja installe
exit 1

:END
