@echo off


Reg delete HKLM\SOFTWARE\RubyInstaller /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Ruby n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd lsc
chmod ugo+rwx *
uninstall.exe /S
cd "C:\Program Files"
chmod ugo+rwx "C:\Program Files\ruby"
cd \
rmdir "\Program Files\ruby" /s /q

cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir Ruby /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del SciTE.lnk /q
cd \

echo Desinstallation terminee


:end