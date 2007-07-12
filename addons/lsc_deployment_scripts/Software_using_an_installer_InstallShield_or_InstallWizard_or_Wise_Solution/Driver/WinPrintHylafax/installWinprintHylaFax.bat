@echo off
REM WinPrintHylafax est un driver qui permet de créer une imprimante virtuelle afin de pouvoir à travers un serveur WEB envoyer et recevoir des FAX

Reg QUERY "HKLM\SOFTWARE\WinprintHylafax" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
WinprintHylaFAX-1.2.8.exe /S
echo Installation terminee.


Reg ADD "HKLM\SOFTWARE\WinprintHylafax" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END