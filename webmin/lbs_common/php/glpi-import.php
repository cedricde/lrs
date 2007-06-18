#!/var/lib/lrs/php -q
<?

include("./phplib/db_mysql.inc");

class DB_GLPI extends DB_Sql {   
   var $Host     = "localhost";
   var $Database = "glpi";
   var $User     = "root";
   var $Password = "";

   var $classname = "DB_GLPI";	   
   function haltmsg($msg) {
	printf("</td></table><b>Database error:</b> %s<br>\n", $msg);
	printf("<b>MySQL Error</b>: %s (%s)<br>\n",
		$this->Errno, $this->Error);
   }
}

$cli = array();
$sql = new DB_GLPI;
$sql->query("select c.id, c.name, e.completename, c.FK_entities from glpi_computers c ,glpi_entities e 
	     where c.FK_entities = e.ID or c.FK_entities = 0");
while ($sql->next_record()) 
{
    $id = $sql->f("id");
    $name = $sql->f("name");
    $group = $sql->f("completename");
    $ent = $sql->f("FK_entities");
    // echo "$ent $id $name=$group\n";
    if ($ent == 0) $group = "";
    $group = preg_replace("/ > /i", "/", $group);
    $cli[] = array( "id" => $id, 
		    "name" => $name, 
		    "group" => $group, 
		    "ent" => $ent);
}

foreach($cli as $key => $val)
{
    // get the MAC address
    $sql->query("select specificity from glpi_computer_device where device_type=5 and FK_computers=".$val[id]);
    while($sql->next_record()) {
	$mac = $sql->f("specificity");
	break; // Get the 1st MAC address only
    }
    print $mac." Dynamic ".$val[group]."/".$val[name]."\n";
}

?>