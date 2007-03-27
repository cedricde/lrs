<?php
function return_html_state($state)
{
	$state_html = array(
		"upload_in_progress" => "<span class=\"state-upload-in-progress\">Transfert en cours</span>",
		"upload_done" => "<span class=\"state-upload-done\">Transfert termin�</span>",
		"upload_failed" => "<span class=\"state-upload-failed\">Transfert �chou�</span>",
		"execution_in_progress" => "<span class=\"state-execution-in-progress\">Ex�cution en cours</span>",
		"execution_done" => "<span class=\"state-execution-done\">Ex�cution termin�e</span>",
		"execution_failed" => "<span class=\"state-execution-failed\">Ex�cution �chou�e</span>",
		"delete_in_progress" => "<span class=\"state-delete-in-progress\">Suppression en cours</span>",
		"delete_done" => "<span class=\"state-delete-done\">Suppression termin�e</span>",
		"delete_failed" => "<span class=\"state-delete-failed\">Suppression �chou�e</span>",
		"not_reachable" => "<span class=\"state-not-reachable\">Connexion impossible</span>",
		"done" => "<span class=\"state-done\">Termin�</span>",
		"pause" => "<span class=\"state-pause\">En pause</span>",
		"stop" => "<span class=\"state-done\">Arr�t�</span>",
		"scheduled" => "<span class=\"state-scheduler\">Planifi�</span>",
		"?" => "<span class=\"state-unknown\">?</span>"
	);
	
	return $state_html[$state];
}
?>
