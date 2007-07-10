@echo off

Reg QUERY "HKLM\SOFTWARE\foldersize" /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
msiexec.exe /i FolderSize-2.3.msi /qn /norestart
echo Installation terminee.
mv "C:\lsc\info + utilisation foldersize.txt" "C:\Program Files\FolderSize"  
cd "C:\Program Files\FolderSize"
chmod ugo+rwx "info + utilisation foldersize.txt"
cd \


Reg ADD "HKLM\SOFTWARE\foldersize" /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1

:END
