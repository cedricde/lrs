@echo off


Reg QUERY "HKLM\SOFTWARE\LameFE" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"LameFE240_setup.exe" /S 

REM pour creer un raccourci on se sert de l executable Shortcut 

REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\lameFE.lnk" /a:c /t:"C:\Program Files\LameFE\lameFE.exe" 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\uninst-LameFE.lnk" /a:c /t:"C:\Program Files\LameFE\uninst-LameFE.exe" 
 
cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir LameFE
chmod ugo+rwx LameFE
cd LameFE
cp  "C:\Documents and Settings\All Users\Bureau\lameFE.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\uninst-LameFE.lnk" .

cd\
cd "C:\Documents and Settings\All Users\Bureau"
del uninst-LameFE.lnk /q
cd \

echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\LameFE" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END

