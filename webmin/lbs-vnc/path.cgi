<?php
# one of the module config files
$FILE = "/etc/webmin/lrs-inventory/config";
$assocTable = lib_read_file($FILE);

# cette variable controle l'emplacement des templates 
#$chemin_templates="./tmpl";
$chemin_templates = $assocTable["chemin_templates"];

# le chemin du dossier ou se trouve les fichiers CSV
# en pratique, le script transfert.php les place dans le dossier courant
# $chemin_CSV="./reception_agent";
$chemin_CSV = $assocTable["chemin_CSV"];

# le chemin de l'arborescence qui sera utilisé pour constitué le menu
# $chemin_menu="./Menus";
$chemin_menu = $assocTable["chemin_menu"];

# la ou se trouve les fichiers ini du LBS
#$chemin_LBS="./LBS";
$chemin_LBS = $assocTable["chemin_LBS"];

# contient les infos rentrés a la main par l'utilisateur.
#$chemin_info="./Info";
$chemin_info = $assocTable["chemin_info"];

# le chemin des CSV concernant le reseau
# correpond a un sous repertoire des CSV.
$chemin_network=$chemin_CSV . "/Network";

# chemin du répertoire Results, qui est un sous-répertoire de CSV
$chemin_results=$chemin_CSV . "/Results";

# couleur employée dans la présentation
$mauve_fonce="#9999ff";
$mauve_clair="#e2d1f9";
$gris_clair="#e2e2e2";
$vert="#35b4c3";
$vert_clair="#97bcc9";

?>