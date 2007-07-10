@echo off


REM la desinstallation meme avec les parametres silencieux demande une confirmation a l utilisateur si il veut garder ces connexions sauvegardees donc on supprime

Reg delete HKLM\SOFTWARE\putty /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel PuTTy n est pas installe
exit 1
GOTO end


:0


REM on supprime le repertoire PuTTY place dans Program Files 
echo debut de la desinstallation
cd \
cd "C:\Program Files\PuTTY"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\PuTTY"
cd \
rmdir "\Program Files\PuTTY" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir "PuTTY" /s /q
cd \

reg delete "HKLM\SOFTWARE\Classes\PuTTYPrivateKey" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\PuTTY_is1"

echo Desinstallation terminee


:end