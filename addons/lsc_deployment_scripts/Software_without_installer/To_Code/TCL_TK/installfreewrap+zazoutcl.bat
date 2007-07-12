@echo off


Reg QUERY "HKLM\SOFTWARE\tcltk" /v Flag >nul
goto %ERRORLEVEL%

:1

echo Debut de l'installation

REM les logiciels pour TCL/TK n'ont pas d'installateur donc on les copie directement dans program files et on place les executables sur le bureau et dans "démarrer" pour tous les utilisateurs

cd \
REM fais une copie dans le repertoire program files
cd C:\Program Files\
cp -r "C:\lsc\TCL TK" .
chmod ugo+rwx "C:\Program Files\TCL TK" 
cd "C:\Program Files\TCL TK"
chmod ugo+rwx *
cd \


cd C:\lsc

REM pour creer un raccourci on se sert de l executable Shortcut 


REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\freewrap.lnk" /a:c /t:"C:\Program Files\TCL TK\freewrap62\freewrap.exe" 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\tclsh83.lnk" /a:c /t:"C:\Program Files\TCL TK\ZazouTcl\bin\tclsh.exe" 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\tclsh.lnk" /a:c /t:"C:\Program Files\TCL TK\ZazouTcl\bin\tclsh.exe" 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\wish83.lnk" /a:c /t:"C:\Program Files\TCL TK\ZazouTcl\bin\wish83.exe" 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\wish.lnk" /a:c /t:"C:\Program Files\TCL TK\ZazouTcl\bin\wish.exe" 


cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir "TCL TK"
chmod ugo+rwx "TCL TK"
cd "TCL TK"
cp  "C:\Documents and Settings\All Users\Bureau\freewrap.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\tclsh83.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\tclsh.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\wish83.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\wish.lnk" .
cd \

cd "C:\Documents and Settings\All Users\Bureau\"
del freewrap.lnk /q
del tclsh83.lnk /q
del tclsh.lnk /q
del wish83.lnk /q
del wish.lnk /q

cd \

REM création d'un flag dans la BDR ainsi qu'une clé
reg add "HKLM\SOFTWARE\tcltk" /v Flag /t REG_DWORD /d "1" /f 

echo Installation terminee.
goto END

:0

echo logiciel deja installe
exit 1

:END
