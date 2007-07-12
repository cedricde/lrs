REM cherche dans C:\ tous les emplacements contenant les fichiers Scribus
dir c:\ /s /b | find "gnumeric.exe"
dir c:\ /s /b | find "Gnumeric Spreadsheet.lnk"



REM on cherche dans la base de registre les informations sur le logiciel, a savoir le numero de version et le nom

reg query "HKU\.DEFAULT\SOFTWARE\GTK\2.0\Gnumeric" /v Path 

reg query "HKU\.DEFAULT\SOFTWARE\GTK\2.0\Gnumeric" /v Version 