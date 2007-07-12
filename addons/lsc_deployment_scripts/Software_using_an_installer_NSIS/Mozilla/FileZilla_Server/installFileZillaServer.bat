@echo off

Reg QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FileZilla Server" /v Flag >nul
goto %ERRORLEVEL%

:1


REM on tue le processus qui lance le serveur FileZilla automatiquement à la fin de l installation


echo Debut de l'installation
start /wait FileZilla_Server-0_9_23.exe /S
taskkill /IM "FileZilla Server Interface.exe" /F
net stop "FileZilla Server"
REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /V "FileZilla Server Interface" /F
sc config "FileZilla Server" start= demand


cd \
cd C:\WINDOWS\System32\
cp "C:\lsc\Framadyn\Framadyn.dll" .
cd \

cd lsc

REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\FileZilla server.lnk" /a:c /t:"C:\Program Files\FileZilla Server\FileZilla server.exe"

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\FileZilla Server Interface.lnk" /a:c /t:"C:\Program Files\FileZilla Server\FileZilla Server Interface.exe" 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\Uninstall.lnk" /a:c /t:"C:\Program Files\FileZilla Server\Uninstall.exe" 
 
cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir "FileZilla Server"
chmod ugo+rwx "FileZilla Server
cd "FileZilla Server
cp  "C:\Documents and Settings\All Users\Bureau\FileZilla server.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\FileZilla Server Interface.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\Uninstall.lnk" .


cd\
cd "C:\Documents and Settings\All Users\Bureau"
del Uninstall.lnk /q
cd "C:\Documents and Settings\All Users\Bureau"
del "FileZilla Server Interface.lnk" /q
cd \

echo Installation terminee.

Reg ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FileZilla Server" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END