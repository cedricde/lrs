@echo off

REM recherche dans la BDR si le logiciel infrarecorder est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY HKLM\SOFTWARE\infrarecorder /v Flag >nul
goto %ERRORLEVEL%

:1

echo Debut de l'installation

REM le logiciel infrarecorder n'a pas d'installateur donc on le copie directement dans program files et on place les executables sur le bureau et dans "démarrer" pour tous les utilisateurs

cd \
REM fais une copie dans le repertoire program files
cd C:\Program Files\
cp -r C:\lsc\ir043_unicode .
chmod ugo+rwx "C:\Program Files\ir043_unicode" 
cd \


cd C:\lsc

REM pour creer un raccourci on se sert de l executable Shortcut 


REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\InfraRecorder.lnk" /a:c /t:"C:\Program Files\ir043_unicode\InfraRecorder.exe" 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\irExpress.lnk" /a:c /t:"C:\Program Files\ir043_unicode\irExpress.exe" 

cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir ir043_unicode
chmod ugo+rwx ir043_unicode
cd ir043_unicode
cp  "C:\Documents and Settings\All Users\Bureau\irExpress.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\InfraRecorder.lnk" . 

cd \

REM création d'un flag dans la BDR ainsi qu'une clé
reg add HKLM\SOFTWARE\infrarecorder /v Flag /t REG_DWORD /d "1" /f 

echo Installation terminee.
goto END

:0

echo logiciel deja installe
exit 1

:END
