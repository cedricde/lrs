<!-- BEGIN all -->
<h2>Sauvegarde de la configuration du LRS</h2>
<p>Si vous avez effectu� des modifications dans la configuration syst�me du
LRS (dans /etc), vous pouvez sauvegarder les fichiers essentiels de configuration
dans /tftpboot/revoboot/backup/. Si vous sauvegardez sur bande /tftpboot, vous
pourrez alors r�cup�rer facilement la configuration apr�s r�-installation du LRS
suite � un crash syst�me.</p>
<form><input type=submit name="saveconf" value="Sauvegarder"></form>

<h2>Restauration de la configuration LRS</h2>
<p>Derni�re sauvegarde: {LAST}</p>

<form><input type=submit name="loadconf" value="Restaurer la derni�re configuration"></form>

<!-- END all -->