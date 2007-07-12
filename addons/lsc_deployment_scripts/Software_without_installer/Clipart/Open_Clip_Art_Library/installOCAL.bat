@echo off


REM un installateur existe pour copier ces clipart dans le repertoire share\gallery de OOo, mais cet installateur avec le parametre silencieux installait ces cliparts dans le repertoire share\gallery du repertoire OOo 2.0


REM donc on copie les cliparts dans le repertoire d'OOo trouvé sur le disque du client si bien sur il possede OOo


REM on verifie si OOo existe dans la BDR
Reg QUERY HKLM\SOFTWARE\OpenOffice.org 
goto %ERRORLEVEL%

:1

echo OpenOffice n est pas installe 
exit 1

:0

REM on verifie si on a pas deja installe les cliparts
Reg QUERY HKLM\SOFTWARE\OpenOffice.org /v Flag2 >nul
goto %ERRORLEVEL%

:1


cd \
REM fais une copie dans le repertoire program files OOo\share\gallery
cd C:\Program Files\OpenOffice.org*\share\gallery
cp -r C:\lsc\cliparts018 .
chmod ugo+rwx "C:\Program Files\OpenOffice.org*\share\gallery\cliparts018" 
cd "C:\Program Files\OpenOffice.org*\share\gallery\cliparts018"
chmod ugo+rwx *
cd \

REM création d'un flag dans la BDR 
reg add HKLM\SOFTWARE\OpenOffice.org /v Flag2 /t REG_DWORD /d "1" /f 
goto END

:0

echo les cliparts sont deja installes
exit 1


:END
