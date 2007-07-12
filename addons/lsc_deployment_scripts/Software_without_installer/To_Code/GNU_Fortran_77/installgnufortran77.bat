@echo off

REM recherche dans la BDR si le logiciel GNU Fortran 77 est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\GNU Fortran 77" /v Flag >nul
goto %ERRORLEVEL%

:1

echo Debut de l'installation

REM le logiciel GNU Fortran 77 n'a pas d'installateur donc on le copie directement dans program files et on place les executables sur le bureau et dans "démarrer" pour tous les utilisateurs

REM les executables sont à utiliser dans l invite de commande MSDOS

cd \
REM fais une copie dans le repertoire program files
cd C:\Program Files\
cp -r C:\lsc\G77 .
chmod ugo+rwx "C:\Program Files\G77" 
cd "C:\Program Files\G77"
chmod ugo+rwx *

REM pour creer un raccourci on se sert de l executable Shortcut 


REM on cree des raccourci sur le bureau pour pouvoir le s copier dans le menu demarrer


cd "C:\Documents and Settings\All Users\Bureau\"
mkdir G77
chmod ugo+rwx G77

cd \
cd lsc
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\G77\ar.lnk" /a:c /t:"C:\Program Files\G77\bin\ar.exe" 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\G77\as.lnk" /a:c /t:"C:\Program Files\G77\bin\as.exe" 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\G77\cpp.lnk" /a:c /t:"C:\Program Files\G77\bin\cpp.exe" 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\G77\f771.lnk" /a:c /t:"C:\Program Files\G77\bin\f771.exe" 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\G77\g77.lnk" /a:c /t:"C:\Program Files\G77\bin\g77.exe" 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\G77\gcc.lnk" /a:c /t:"C:\Program Files\G77\bin\gcc.exe" 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\G77\ld.lnk" /a:c /t:"C:\Program Files\G77\bin\ld.exe" 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\G77\make.lnk" /a:c /t:"C:\Program Files\G77\bin\make.exe" 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\G77\utilisation.lnk" /a:c /t:"C:\Program Files\G77\bin\utilisation.txt" 



cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir G77
chmod ugo+rwx G77
cd G77
cp  "C:\Documents and Settings\All Users\Bureau\G77\ar.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\G77\as.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\G77\cpp.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\G77\f771.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\G77\g77.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\G77\gcc.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\G77\ld.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\G77\make.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\G77\utilisation.lnk" .
cd \




REM création d'un flag dans la BDR ainsi qu'une clé
reg add "HKLM\SOFTWARE\GNU Fortran 77" /v Flag /t REG_DWORD /d "1" /f 

echo Installation terminee.
goto END

:0

echo logiciel deja installe
exit 1

:END
