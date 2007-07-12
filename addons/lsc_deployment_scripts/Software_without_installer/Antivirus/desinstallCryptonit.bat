@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\cryptonit /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Cryptonit n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire Cryptonit place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\Cryptonit"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\Cryptonit"
cd \
rmdir "\Program Files\Cryptonit" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir Cryptonit /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del Cryptonit-0.9.7.lnk /q
cd \

echo Desinstallation terminee


:end