<?php
function return_html_state($state)
{
	$state_html = array(
		"upload_in_progress" => "<span class=\"state-upload-in-progress\">Transfert en cours</span>",
		"upload_done" => "<span class=\"state-upload-done\">Transfert terminé</span>",
		"upload_failed" => "<span class=\"state-upload-failed\">Transfert échoué</span>",
		"execution_in_progress" => "<span class=\"state-execution-in-progress\">Exécution en cours</span>",
		"execution_done" => "<span class=\"state-execution-done\">Exécution terminée</span>",
		"execution_failed" => "<span class=\"state-execution-failed\">Exécution échouée</span>",
		"delete_in_progress" => "<span class=\"state-delete-in-progress\">Suppression en cours</span>",
		"delete_done" => "<span class=\"state-delete-done\">Suppression terminée</span>",
		"delete_failed" => "<span class=\"state-delete-failed\">Suppression échouée</span>",
		"not_reachable" => "<span class=\"state-not-reachable\">Connexion impossible</span>",
		"done" => "<span class=\"state-done\">Terminé</span>",
		"pause" => "<span class=\"state-pause\">En pause</span>",
		"stop" => "<span class=\"state-done\">Arrêté</span>",
		"scheduled" => "<span class=\"state-scheduler\">Planifié</span>",
		"?" => "<span class=\"state-unknown\">?</span>"
	);
	
	return $state_html[$state];
}
?>
