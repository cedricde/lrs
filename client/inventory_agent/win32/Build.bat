@echo off

rem Requis:

rem Python Installer (pour .py => .exe)
rem http://paulbaranowski.org/modules.php?name=Downloads&d_op=MostPopular

rem Acte I: auto-configuration de la bestiole
rem (Uniquement la premi�re fois)
Installer\Configure.py

rem Acte II: cr�ation du fichier de specs
Installer\Makespec.py --onefile --noconsole --out Spec --icon Medias\logo-icon.ico Sources\lbs-inventory.py Sources\envoi.py

rem Acte III: cr�ation de l'exe
Installer\Build.py Spec\lbs-inventory.spec
move Spec\lbs-inventory.exe Spec\lrs-inventory.exe
pause