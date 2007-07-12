@echo off

REM recherche dans la BDR si le logiciel Exodus est installe

REM reg QUERY renvoi 0 : succés ou 1 : echec

Reg QUERY "HKLM\SOFTWARE\exodus" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
"exodus_0.9.1.0.exe" /S 


REM l installateur ne cree pas de raccourci donc on utilise un executable shortcut pour en creer

REM on fais un raccourci de l executable sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\Exodus.lnk" /a:c /t:"C:\Program Files\Exodus\Exodus.exe" 

cd \

REM on fais un raccourci de l executable dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir Exodus
chmod ugo+rwx Exodus
cd Exodus
cp  "C:\Documents and Settings\All Users\Bureau\Exodus.lnk" .

cd \
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\exodus" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END



