{action_message}

<p>Fichier : {COMPLETE_PATH_FILE_TO_EDIT}</p>
<form
	method="POST"
	action="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&edit={EDIT_FILE}&current_tab={CURRENT_TAB}"
>
	<textarea
		name="content"
		cols="80"
		rows="25"
	>{CONTENT_DATA}</textarea>
	<p>
		<input name="edit_save_submit" type="submit" value="Enregistrer" />
		<input name="return_submit" type="submit" value="Retour" />
	</p>
</form>
