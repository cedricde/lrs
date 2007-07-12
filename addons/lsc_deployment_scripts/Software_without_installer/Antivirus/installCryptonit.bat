@echo off

REM recherche dans la BDR si le logiciel Cryptonit est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY HKLM\SOFTWARE\cryptonit /v Flag >nul
goto %ERRORLEVEL%

:1

echo Debut de l'installation

REM le logiciel Cryptonit n'a pas d'installateur donc on le copie directement dans program files et on place l executable sur le bureau et dans "démarrer" pour tous les utilisateurs

cd \
REM fais une copie dans le repertoire program files
cd C:\Program Files\
cp -r C:\lsc\Cryptonit .
chmod ugo+rwx "C:\Program Files\Cryptonit" 
cd "C:\Program Files\Cryptonit"
chmod ugo+rwx *
cd \


cd C:\lsc

REM pour creer un raccourci on se sert de l executable Shortcut 


REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\Cryptonit-0.9.7.lnk" /a:c /t:"C:\Program Files\Cryptonit\Cryptonit-0.9.7.exe" 

cd \

REM on fais un raccourci de l executable dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir Cryptonit
chmod ugo+rwx Cryptonit
cd Cryptonit
cp  "C:\Documents and Settings\All Users\Bureau\Cryptonit-0.9.7.lnk" .

cd \

REM création d'un flag dans la BDR ainsi qu'une clé
reg add HKLM\SOFTWARE\cryptonit /v Flag /t REG_DWORD /d "1" /f 

echo Installation terminee.
goto END

:0
echo logiciel deja installe
exit 1

:END
