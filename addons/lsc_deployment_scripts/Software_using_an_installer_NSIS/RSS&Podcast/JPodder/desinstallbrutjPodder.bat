@echo off

REM jPodder a bien un desinstallateur mais celui ci n accepte aucun parametre pour une desinstallation silencieuse

REM On efface donc tous les fichiers et dossiers sur le dique dur ainsi que toutes les cles de la base de registre

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\jPodder /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel jPodder n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire jPodder place dans Program Files

cd \
cd "C:\Program Files\jPodder"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\jPodder"
cd \
rmdir "\Program Files\jPodder" /s /q 


cd \
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir jPodder /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del JPodder.lnk /s

REM on supprime toutes les clés de la BDR
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\jPodder" /f


echo Desinstallation terminee


:end