@echo off

REM Scribus a bien un desinstallateur mais celui ci n accepte aucun parametre pour une desinstallation silencieuse

REM On efface donc tous les fichiers et dossiers sur le dique dur ainsi que toutes les cles de la base de registre



REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Scribus 1.3.3" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Scribus n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\Scribus 1.3.3.9"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\Scribus 1.3.3.9"
cd \
rmdir "\Program Files\Scribus 1.3.3.9" /s /q 

cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir Scribus /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del Scribus.lnk /q
cd \


REM on supprime toutes les clés de la BDR

reg delete "HKLM\SOFTWARE\Scribus" /f
reg delete "HKLM\SOFTWARE\Classes\.sla" /f
reg delete "HKLM\SOFTWARE\Classes\Scribus.Document" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Scribus.exe" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Scribus 1.3.3" /f
echo desinstallation termine 



:end