@echo off


Reg delete HKLM\SOFTWARE\emacs /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Emacs 21.3 n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire emacs-21.3 place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\emacs-21.3"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\emacs-21.3"
cd \
rmdir "\Program Files\emacs-21.3" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir "Emacs 21.3" /s /q
cd \

cd "C:\Documents and Settings\All Users\Bureau"
del emacs.lnk /q
cd \

echo Desinstallation terminee


:end