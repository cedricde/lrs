@echo off

REM PDF spilt and merge a bien un desinstallateur mais celui ci n accepte aucun parametre pour une desinstallation silencieuse

REM On efface donc tous les fichiers et dossiers sur le dique dur ainsi que toutes les cles de la base de registre


Reg delete "HKLM\SOFTWARE\pdf spit and merge" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel PDF spit and merge n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\pdfsam"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\pdfsam"
cd \
rmdir "\Program Files\pdfsam" /s /q 


cd \
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir "PDF Split And Merge" /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del pdfsam-starter.lnk /q
del pdfsam-0.6sr3.lnk /q
cd \


REM on supprime toutes les clés de la BDR

reg delete "HKLM\SOFTWARE\pdf split and merge" /f

reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\pdfsam" /f
echo desinstallation termine 



:end