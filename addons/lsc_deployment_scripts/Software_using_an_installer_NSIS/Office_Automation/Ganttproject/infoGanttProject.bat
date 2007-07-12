REM cherche dans C:\ tous les emplacements contenant les fichiers GanttProject
dir c:\ /s /b | find "ganttproject.exe"
dir c:\ /s /b | find "GanttProject.lnk"



REM on cherche dans la base de registre les informations sur le logiciel, a savoir le numero de version et le nom

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GanttProject" /v DisplayName 

REM GanttProject n a pas de numero de version inscrit dans la BDR néanmoins il s agit de la version 2.0.4