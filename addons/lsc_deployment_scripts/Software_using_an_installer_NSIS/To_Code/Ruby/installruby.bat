@echo off

REM recherche dans la BDR si le logiciel Ruby est installe

Reg QUERY HKLM\SOFTWARE\RubyInstaller /v Flag >nul
goto %ERRORLEVEL%

:1


echo Debut de l'installation
chmod ugo+rx *
ruby186-25.exe /S /D=C:\Program Files\ruby

REM pour creer un raccourci on se sert de l executable Shortcut 

REM on fais un raccourci des executables sur le bureau de chaque utilisateurs 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\SciTE.lnk" /a:c /t:"C:\Program Files\ruby\scite\SciTE.exe" 
 
Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\uninstall.lnk" /a:c /t:"C:\Program Files\ruby\uninstall.exe" 

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\RubyGems Package Manager.lnk" /a:c /t:"C:\Program Files\ruby\bin\gemhelp.bat"

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\Start RubyGems RDoc Server.lnk" /a:c /t:"C:\Program Files\ruby\bin\gem_server.bat"

Shortcut.exe /f:"C:\Documents and Settings\All Users\Bureau\RubyBook Help.lnk" /a:c /t:"C:\Program Files\ruby\doc\ProgrammingRuby.chm"

cd \

REM on fais un raccourci des executables dans le menu Demarrer de chaque utilisateurs
cd "C:\Documents and Settings\All Users\Menu D?marrer\Programmes"
mkdir Ruby
chmod ugo+rwx Ruby
cd Ruby
cp  "C:\Documents and Settings\All Users\Bureau\SciTE.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\uninstall.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\RubyGems Package Manager.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\Start RubyGems RDoc Server.lnk" .
cp  "C:\Documents and Settings\All Users\Bureau\RubyBook Help.lnk" .
chmod ugo+rwx "C:\lsc\Ruby Documentation"
chmod ugo+rwx "C:\lsc\RubyGems"
mv "C:\lsc\Ruby Documentation" .
mv "C:\lsc\RubyGems" .

chmod 777 *


cd "C:\Documents and Settings\All Users\Bureau\"
del uninstall.lnk /q
del "fxri - Interactive Ruby Help & Console.lnk" /q
del "RubyGems Package Manager.lnk" /q
del "Start RubyGems RDoc Server.lnk" /q
del "RubyBook Help.lnk" /q
cd \


echo Installation terminee.


Reg ADD HKLM\SOFTWARE\RubyInstaller /v Flag /t REG_DWORD /d "1" /f
goto END

:0

echo logiciel deja installe
exit 1


:END
