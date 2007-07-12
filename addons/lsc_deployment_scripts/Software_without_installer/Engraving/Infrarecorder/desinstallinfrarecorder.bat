@echo off

REM test dans la BDR si le Flag est à 1( c.a.d infrarecorder installé) ou 0 (infrarecorder pas installé)

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\infrarecorder /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Infrarecorder n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire ir043_unicode place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\ir043_unicode"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\ir043_unicode"
cd \
rmdir "\Program Files\ir043_unicode" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir ir043_unicode /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del InfraRecorder.lnk /q
del irExpress.lnk /q
cd \

echo Desinstallation terminee


:end