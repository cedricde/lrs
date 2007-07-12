@echo off

REM Visioo Writer a bien un desinstallateur mais celui ci n accepte aucun parametre pour une desinstallation silencieuse

REM On efface donc tous les fichiers et dossiers sur le dique dur ainsi que toutes les cles de la base de registre



REM reg delete renvoi 0 : succés ou 1 : echec

Reg delete "HKLM\SOFTWARE\visioowriter" /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel Visioo Writer n est pas installe
exit 1
GOTO end


:0

echo debut de la desinstallation
cd\
cd "C:\visioowriter"
chmod ugo+rwx *
cd ..
chmod ugo+rwx "C:\visioowriter"
cd \
rmdir visioowriter /s /q 


cd \
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
rmdir VisiooWriter /s /q
cd \

REM on supprime toutes les clés de la BDR

reg delete "HKLM\SOFTWARE\visiowriter" /f
reg delete "HKLM\SOFTWARE\Classes\.py" /f
reg delete "HKLM\SOFTWARE\Classes\.pyc" /f
reg delete "HKLM\SOFTWARE\Classes\.pyd" /f
reg delete "HKLM\SOFTWARE\Classes\.pyo" /f
reg delete "HKLM\SOFTWARE\opendocument.WriterDocument.1\shell\Visionner" /f
reg delete "HKLM\SOFTWARE\soffice.StarWriterDocument.6\shell\Visionner" /f
reg delete "HKLM\SOFTWARE\txtfile\shell\Visionner" /f


reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\python.exe" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\VisioWriter" /f
echo desinstallation termine 



:end