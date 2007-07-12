@echo off


Reg QUERY HKLM\SOFTWARE\emacs /v Flag >nul
goto %ERRORLEVEL%

:1

echo Debut de l'installation

REM le logiciel emacs 21.3 n'a pas d'installateur donc on le copie directement dans program files et on place les executables sur le bureau et dans "démarrer" pour tous les utilisateurs

cd \
REM fais une copie dans le repertoire program files
cd C:\Program Files\
cp -r "C:\lsc\emacs-21.3" .
chmod ugo+rwx "C:\Program Files\emacs-21.3" 
cd "C:\Program Files\emacs-21.3"
chmod ugo+rwx *
cd \


cd C:\lsc

REM pour creer un raccourci on se sert de l executable Shortcut 


REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\emacs.lnk" /a:c /t:"C:\Program Files\emacs-21.3\bin\emacs.exe" 

cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir "Emacs 21.3"
chmod ugo+rwx "Emacs 21.3"
cd "Emacs 21.3"
cp  "C:\Documents and Settings\All Users\Bureau\emacs.lnk" .

cd \

REM création d'un flag dans la BDR ainsi qu'une clé
reg add HKLM\SOFTWARE\emacs /v Flag /t REG_DWORD /d "1" /f 

echo Installation terminee.
goto END

:0

echo logiciel deja installe
exit 1

:END
