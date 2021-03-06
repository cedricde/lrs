; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!
; $Id: setup.iss 1923 2005-01-31 17:06:56Z nicolas $

[Setup]
; will install in C:\Program Files\LRS Inventory Agent
DefaultDirName={pf}\LRS Inventory Agent
; require to update some registry keys
PrivilegesRequired=admin
; Create a group
DefaultGroupName=Linbox/LRS Inventory Agent
DisableProgramGroupPage=false

AppName={cm:LrsInventoryAgent}
AppCopyright=� 2004 Linbox / Free & Alter Soft
AppPublisher=Linbox / Free & Alter Soft
AppPublisherURL=http://www.freealter.com
AppSupportURL=http://www.freealter.com
AppUpdatesURL=ftp://ftp.linbox.com/pub/lbs/inventory

; App name and version
; Dont forget to change all entries
AppVerName={cm:LrsInventoryAgent} 2.2.0
; version as detected by Windows
AppVersion=2.2.0
; output file name
OutputBaseFilename=LRS-Inventory-2.2.0

; Where to put our setup
OutputDir=.

VersionInfoCompany=Linbox / Free & Alter Soft
VersionInfoDescription=LRS Inventory Agent
VersionInfoTextVersion=Part of Linbox Backup Server - Client part
VersionInfoVersion=2.2.0

SetupIconFile=..\Medias\logo-icon.ico

WizardImageStretch=false
WizardSmallImageBackColor=$D6B6FF
WizardSmallImageFile=..\Medias\logo-small.bmp

WizardImageFile=..\Medias\penguin-big-high.bmp

WindowVisible=true
BackColor=$a5c7ff
BackColor2=$264fea
ShowComponentSizes=true

UserInfoPage=true
ShowLanguageDialog=yes

[Components]
;Name: "demon"; Description: "LRS Inventory Daemon"; Flags: fixed
;Name: "ocs"; Description: "OCS Inventory"; Flags: fixed

[Types]
; Name: "custom"; Description: "LRS Daemon Agent Only"; Flags: iscustom
; Name: "full"; Description: "Full installation"

[Dirs]
; (misc) : Penser � respecter la casse !!!
Name: {app}; Permissions: everyone-modify

[Files]
Source: ..\Spec\lrs-inventory.exe; DestDir: {app}; Flags: ignoreversion; BeforeInstall: GetIPAddr
Source: ..\OCS\*; DestDir: {app}\ocs\; Flags: ignoreversion recursesubdirs

[Registry]
; un classique lancement au d�marrage.
; marche de 95 a 2000 et sans doute XP aussi.
; mis en place pour toutes les connexions.
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\CurrentVersion\Run; ValueType: string; ValueName: LRS-Inventory agent; ValueData: {app}\lrs-inventory.exe; Flags: uninsdeletekey

; pour retrouver l'appli facilement
Root: HKCR; Subkey: Linbox\lrs-inventory; ValueType: string; ValueName: Path; ValueData: {app}; Permissions: everyone-read; Flags: uninsdeletekey
Root: HKCR; Subkey: Linbox\lrs-inventory; ValueType: string; ValueName: UserName; ValueData: {userinfoname}; Permissions: everyone-read; Flags: uninsdeletekey
Root: HKCR; Subkey: Linbox\lrs-inventory; ValueType: string; ValueName: Company; ValueData: {userinfoorg}; Permissions: everyone-read; Flags: uninsdeletekey

[CustomMessages]
fr.LrsInventoryAgent=Agent d'inventaire du LRS
en.LrsInventoryAgent=Agent d'inventaire du LRS
fr.GiveLrsIpAdress=Nom (ou adresse IP) du LRS
en.GiveLrsIpAdress=LRS name (or IP Adress)
fr.WhereIsTheLrs=Comment localiser le LRS ?
en.WhereIsTheLrs=Where is the LRS ?
fr.MustKnowTheLocation=L'Inventaire doit savoir comment joindre le LRS, par son adresse IP ou son nom. Vous pouvez v�rifier cette donn�e avec un navigateur WEB tel que Internet Explorer.
en.MustKnowTheLocation=The Inventory must know how to reach the LRS, either by its name or IP Adress. You can check it in a web browser, for exemple in Internet Explorer.

[Code]
procedure GetIPAddr;
var
  notentered: Boolean;
  answer: String;
begin

// one can override default server by specifing /lrsserver=<my-server> with the command line
// default server: lbs
  answer:=ExpandConstant('{param:lrsserver|lbs}');

// wizard shown only if we are not silenced
  if (not WizardSilent()) then begin
    notentered:=True;
    ScriptDlgPageOpen();

    ScriptDlgPageSetCaption(ExpandConstant('{cm:GiveLrsIpAdress}'));
    ScriptDlgPageSetSubCaption1(ExpandConstant('{cm:WhereIsTheLrs}'));
    ScriptDlgPageSetSubCaption2(ExpandConstant('{cm:MustKnowTheLocation}'));
    ScriptDlgPageShowBackButton(False);

    while (notentered or (Length(answer)=0)) do begin
      InputQuery('LRS name or IP Adress', answer);
      notentered:=False;
      if (Length(answer)=0) then begin
        MsgBox('Invalid adress !', mbError, MB_OK);
      end
    end
    ScriptDlgPageClose(True);
  end

  SetIniString('conf', 'serveur_apps', 'http://' + answer + '/lbs-transfert/transfert.php', ExpandConstant('{app}\config.ini'));
end;



[Languages]
Name: fr; MessagesFile: compiler:Languages\French.isl; LicenseFile: ..\Setup\LICENCE.txt; InfoBeforeFile: ..\Setup\INFO.fr.txt
Name: en; MessagesFile: compiler:Default.isl; LicenseFile: ..\Setup\LICENCE.txt; InfoBeforeFile: ..\Setup\INFO.en.txt
