Reg delete "HKLM\SOFTWARE\screensaver" /v Flag /f 
goto %ERRORLEVEL%

:1

echo les economiseurs d ecran ne sont pas installees
exit 1
GOTO end


:0

REM on supprime toutes les economiseurs d ecran ajoutées
echo debut de la desinstallation
cd \
cd "C:\WINDOWS\System32"
chmod ugo+rwx *

del Cyclone.scr /q
del Euphoria.scr /q
del FieldLines.scr /q
del Flocks.scr /q
del Flux.scr /q
del Helios.scr /q
del Hyperspace.scr /q
del Lattice.scr/q
del Plasma.scr /q
del Skyrocket.scr /q
del SolarWinds.scr /q

cd \
echo Desinstallation terminee


:end