@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\gnumeric" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Gnumeric n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd\
cd "C:\Program Files\Gnumeric"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\Gnumeric"
cd \
rmdir "\Program Files\Gnumeric" /s /q 

cd C:\WINDOWS\Prefetch
del GNUMERIC-1.6.3-WIN32-2.EXE-2D0D9F62.pf /q

cd \
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir Gnumeric /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del gnumeric.lnk /q
cd \


REM on supprime toutes les clés de la BDR

reg delete "HKLM\SOFTWARE\gnumeric" /f
reg delete "HKLM\SOFTWARE\Classes\.gnumeric" /f
reg delete "HKLM\SOFTWARE\Classes\Gnumeric.XML" /f



cd\
echo Desinstallation terminee


:end