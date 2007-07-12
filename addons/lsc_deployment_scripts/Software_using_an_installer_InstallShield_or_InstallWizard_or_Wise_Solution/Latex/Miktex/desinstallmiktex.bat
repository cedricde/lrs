@echo off

REM miktex n a pas de desinstallateur

REM On efface donc tous les fichiers et dossiers sur le dique dur ainsi que toutes les cles de la base de registre



REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\miktex" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel miktex n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\Program Files\MiKTeX 2.6"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\MiKTeX 2.6"
cd \
rmdir "\Program Files\MiKTeX 2.6" /s /q 


cd \
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir "MiKTeX 2.6" /s /q
cd \


REM on supprime toutes les clés de la BDR

reg delete "HKLM\SOFTWARE\miktex" /f
reg delete "HKLM\SOFTWARE\MiKTeX.org" /f
echo desinstallation termine 



:end