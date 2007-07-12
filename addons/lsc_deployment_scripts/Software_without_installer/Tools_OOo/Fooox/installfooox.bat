@echo off

REM recherche dans la BDR si le logiciel Fooox est installe

REM reg QUERY renvoi 0 : succ�s ou 1 : echec

Reg QUERY HKLM\SOFTWARE\fooox /v Flag >nul
goto %ERRORLEVEL%

:1

echo Debut de l'installation

REM le logiciel fooox n'a pas d'installateur donc on le copie directement dans program files et on place un raccourci des executables sur le bureau et dans "d�marrer" pour tous les utilisateurs

cd \
REM fais une copie dans le repertoire program files
cd C:\Program Files\
cp -r C:\lsc\fooox .
chmod ugo+rwx "C:\Program Files\fooox" 
cd "C:\Program Files\fooox"
chmod ugo+rwx *
cd \


cd C:\lsc

REM pour creer un raccourci on se sert de l executable Shortcut 


REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\fooox001b10.lnk" /a:c /t:"C:\Program Files\fooox\fooox001b10.exe" 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\fooox.lnk" /a:c /t:"C:\Program Files\fooox\fooox.gif"


cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir Fooox
chmod ugo+rwx Fooox
cd Fooox
cp  "C:\Documents and Settings\All Users\Bureau\fooox001b10.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\fooox.lnk" .

cd \

REM cr�ation d'un flag dans la BDR ainsi qu'une cl�
reg add HKLM\SOFTWARE\fooox /v Flag /t REG_DWORD /d "1" /f 

echo Installation terminee.
goto END

:0

echo logiciel deja installe
exit 1

:END
