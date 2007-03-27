#!/var/lib/lrs/php
<?php
if ($_GET["mac"] == "") {
	include("commands_states_on_group_and_profile.php");
} else {
	include("commands_states_on_host.php");
}
?>
