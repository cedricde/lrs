@echo off

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\LameFE" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel LameFE n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd "C:\Program Files\LameFE"
chmod ugo+rwx *
start /wait uninst-LameFE.exe /S
taskkill /IM "Au_.exe" /F
cd\
chmod ugo+rwx "C:\Program Files\LameFE"
rmdir "\Program Files\LameFE" /s /q
cd \

REM lorsqu on tue le processus Au_.exe les raccourci ne sont pas supprimés

REM ces raccourcis se trouve sous la session locale et pas dans la session "All User", donc on utilise une boucle for pour supprimer les raccourcis

FOR /r "C:\Documents and Settings" %%i In ("lameFE.*","uninst-LameFE.*") Do del "%%~fi" /s /q

echo Desinstallation terminee


:end