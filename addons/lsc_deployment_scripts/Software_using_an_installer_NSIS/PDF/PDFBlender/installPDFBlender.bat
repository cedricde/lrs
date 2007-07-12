@echo off

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\PDF Blender" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"PDFBlenderSetup1.1.2.exe" /S 
echo Installation terminee.


REM l installateur ne cree pas de raccourci sur le bureau et  dans le menu "demarrer"


REM pour creer un raccourci on se sert de l executable Shortcut 

REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\PDFBlender.lnk" /a:c /t:"C:\Program Files\PDF Blender\PDFBlender.exe" 
 
cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir PDFBlender
chmod ugo+rwx PDFBlender
cd PDFBlender
cp  "C:\Documents and Settings\All Users\Bureau\PDFBlender.lnk" .

cd \




Reg ADD "HKLM\SOFTWARE\PDF Blender" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END