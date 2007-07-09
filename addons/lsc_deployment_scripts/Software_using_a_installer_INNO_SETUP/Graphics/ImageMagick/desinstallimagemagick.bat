@echo off


Reg delete HKLM\SOFTWARE\imageMagick /v Flag /f 
goto %ERRORLEVEL%

:1

echo Le logiciel ImageMagick n est pas installe
exit 1
GOTO end


:0


echo debut de la desinstallation
cd \
cd "Program Files\ImageMagick-6.3.4-Q16"
chmod ugo+rwx *
unins000.exe /sp- /verysilent /norestart
cd ..
chmod ugo+rwx "C:\Program Files\ImageMagick-6.3.4-Q16"
cd \
rmdir "\Program Files\ImageMagick-6.3.4-Q16" /s /q
echo Desinstallation terminee


:end