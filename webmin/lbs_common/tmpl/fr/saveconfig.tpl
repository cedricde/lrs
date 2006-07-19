<!-- BEGIN all -->
<h2>Sauvegarde de la configuration du LRS</h2>
<p>Si vous avez effectué des modifications dans la configuration système du
LRS (dans /etc), vous pouvez sauvegarder les fichiers essentiels de configuration
dans /tftpboot/revoboot/backup/. Si vous sauvegardez sur bande /tftpboot, vous
pourrez alors récupérer facilement la configuration après ré-installation du LRS
suite à un crash système.</p>
<form><input type=submit name="saveconf" value="Sauvegarder"></form>

<h2>Restauration de la configuration LRS</h2>
<p>Dernière sauvegarde: {LAST}</p>

<form><input type=submit name="loadconf" value="Restaurer la dernière configuration"></form>

<!-- END all -->