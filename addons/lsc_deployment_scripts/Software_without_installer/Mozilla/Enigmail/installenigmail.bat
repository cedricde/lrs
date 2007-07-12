@echo off


REM il n y a pas d installateur d enigmail, simplement on copie l extension de format .xpi(specifique a mozilla) dans le repertoire extensions de Mozilla Firefox et ou Mozilla Thunderbird et a la prochaine utilisation par le client de ce naviguateur une boite de dialogue s ouvre lui demandant si il veut installer ou non ce logiciel. L installation se fait automatiquement  


REM on verifie si Mozilla Firefox ou et Mozilla Thunderbird existe dans la BDR
Reg QUERY HKLM\SOFTWARE\Mozilla
goto %ERRORLEVEL%

:1

echo Mozilla(Firefox et ou Thunderbird) n est pas installe 
exit 1

:0

REM on verifie si on a pas deja installe l extension engmail pour mozilla firefox et ou thunderbird 
Reg QUERY HKLM\SOFTWARE\enigmail /v Flag2 >nul
goto %ERRORLEVEL%

:1


cd \
REM on fais une copie dans le repertoire program files, Mozilla Firefox\extensions et ou Mozilla Thunderbird\extensions 
cd "C:\Program Files\Mozilla Thunderbird\extensions"
cp -r C:\lsc\enigmail-0.95.1-tb+sm.xpi .
chmod ugo+rwx "cd C:\Program Files\Mozilla Thunderbird\extensions\enigmail-0.95.1-tb+sm.xpi" 
cd \
cd "C:\Program Files\Mozilla Firefox\extensions"
cp -r C:\lsc\enigmail-0.95.1-tb+sm.xpi .
chmod ugo+rwx "cd C:\Program Files\Mozilla Firefox\extensions\enigmail-0.95.1-tb+sm.xpi"
cd \

REM création d'un flag dans la BDR 
reg add HKLM\SOFTWARE\Mozilla /v Flag2 /t REG_DWORD /d "1" /f 
goto END

:0

echo l extension enigmail est deja installe
exit 1


:END
