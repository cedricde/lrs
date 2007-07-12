@echo off


Reg QUERY HKLM\SOFTWARE\mtasc /v Flag >nul
goto %ERRORLEVEL%

:1

echo Debut de l'installation

REM le logiciel MTASC n'a pas d'installateur donc on le copie directement dans program files et on place les executables sur le bureau et dans "démarrer" pour tous les utilisateurs

REM MTASC s utilise en ligne de commande

cd \
REM fais une copie dans le repertoire program files
cd C:\Program Files\
cp -r C:\lsc\mtasc-1.13 .
chmod ugo+rwx "C:\Program Files\mtasc-1.13" 
cd "C:\Program Files\mtasc-1.13"
chmod ugo+rwx *
cd \


cd C:\lsc

REM pour creer un raccourci on se sert de l executable Shortcut 


REM on fais un raccourci de l executable et du "mode d emploi" sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\mtasc.lnk" /a:c /t:"C:\Program Files\mtasc-1.13\mtasc.exe" 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\utilisation de mtasc.lnk" /a:c /t:"C:\Program Files\mtasc-1.13\utilisation de mtasc.txt" 

cd \

REM on fais un raccourci dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir mtasc-1.13
chmod ugo+rwx mtasc-1.13
cd mtasc-1.13
cp  "C:\Documents and Settings\All Users\Bureau\mtasc.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\utilisation de mtasc.lnk" .
cd \

REM création d'un flag dans la BDR ainsi qu'une clé
reg add HKLM\SOFTWARE\mtasc /v Flag /t REG_DWORD /d "1" /f 

echo Installation terminee.
goto END

:0

echo logiciel deja installe
exit 1

:END
