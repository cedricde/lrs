@echo off

REM recherche dans la BDR si les economiseurs d ecran sont deja installes


Reg QUERY HKLM\SOFTWARE\screensaver /v Flag >nul
goto %ERRORLEVEL%

:1

echo Debut de l'installation

REM  on copie directement les economiseurs d ecran dans WINDOWS\System32 

echo Debut de l'installation
cd \
cd C:\lsc\screensaver\
chmod ugo+rwx *
cp *.scr C:\WINDOWS\System32
cd \

cd C:\lsc

REM on execute cette application pour permettre l affichage correcte de ces economiseurs d ecrans
OpenALwEAX.exe /S

cd \

REM création d'un flag dans la BDR ainsi qu'une clé
reg add HKLM\SOFTWARE\screensaver /v Flag /t REG_DWORD /d "1" /f 

echo Installation terminee.
goto END

:0

echo economiseur d ecran deja installe
exit 1

:END
