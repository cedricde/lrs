@echo off

REM Abiword a bien un desinstallateur mais celui ci n accepte aucun parametre pour une desinstallation silencieuse

REM On efface donc tous les fichiers et dossiers sur le dique dur ainsi que toutes les cles de la base de registre

REM test dans la BDR si le Flag est à 1( c.a.d Abiword installé) ou 0 (Abiword pas installé)

REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete HKLM\SOFTWARE\AbiSuite /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel AbiSuite n est pas installe
exit 1
GOTO end


:0

REM on supprime le repertoire Abisuite2 place dans Program Files

cd \
cd "C:\Program Files\AbiSuite2"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\Program Files\AbiSuite2"
cd \
rmdir "\Program Files\AbiSuite2" /s /q 


cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir "AbiWord Word Processor" /s /q
cd \


REM on supprime toutes les clés de la BDR

reg delete "HKLM\SOFTWARE\AbiSuite" /f
reg delete "HKLM\SOFTWARE\Classes\.abw" /f
reg delete "HKLM\SOFTWARE\Classes\.awt" /f
reg delete "HKLM\SOFTWARE\Classes\.zabw" /f
reg delete "HKLM\SOFTWARE\Classes\AbiSuite.Abiword" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AbiWord2" /f


echo Desinstallation terminee


:end