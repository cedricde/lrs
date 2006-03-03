<?php
/*
 * Created on 20 juin 2005
 *
 * To change the template for this generated file go to
 * Window - Preferences - PHPeclipse - PHP - Code Templates
 */
 
	include_once('Drivers/Csv/CsvDefinition.php');


	$dp = opendir('Drivers/Csv/Definitions');

	while ( $file = readdir($dp) )
	{
		if ( preg_match('/(.*)\.xml/',$file,$matches) )
		{
			$type = $matches[0];
			
			$file = "Drivers/Csv/Definitions/$file";
			
			$definition = CsvDefinition::loadFromFile($file);
			
			$max = -1;
			$model;
			
			foreach ( $definition->m_Versions as $version )
			{
				if ( $version->getFieldCount()>$max )
				{
					$max = $version->getFieldCount();
					$model = $version;
				}
			}
			
			print 'CREATE TABLE '. $definition->getType() .'<br/>(<ul>';
			print 'id MEDIUMINT(9) UNSIGNED NOT NULL auto_increment,<br/>';
			
			foreach ( $version->m_Fields as $field )
			{
				if ( $field!='Host' && $field!='Unused' )
					print "$field VARCHAR(255),<br/>";
			}
			
			print 'PRIMARY KEY(id)';
			print '</ul>);<p>';
			
			$join = strtolower($definition->getType());
			
			if ($join!='machine')
			{
				print 'CREATE TABLE has'. $definition->getType() .'<br/>(<ul>';
				print 'machine MEDIUMINT(9) UNSIGNED NOT NULL,<br/>';
				print 'inventory MEDIUMINT(5) UNSIGNED NOT NULL,<br/>';
				print $join .' MEDIUMINT(9) UNSIGNED NOT NULL,<br/>';
				print 'PRIMARY KEY (machine,inventory,'. $join .')<br/>';
				print '</ul>);<p>';
			}
		}
	}

	closedir($dp);
 
?>
CREATE TABLE Inventory<br/>
(<ul>
id MEDIUMINT(8) UNSIGNED NOT NULL auto_increment,<br/>
Date DATE NOT NULL default '0000-00-00',<br/>
PRIMARY KEY (id)<br/>
</ul>
);

<p>

CREATE TABLE Version<br/>
(<ul>
VersionNumber TINYINT(4) unsigned NOT NULL default '0'<br/>
</ul>);

<p>

INSERT INTO Version VALUES ('1');

<p>

CREATE TABLE CustomField<br/>
(<ul>
id MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT,<br/>
machine MEDIUMINT UNSIGNED NOT NULL,<br/>
Key VARCHAR(32) NOT NULL,<br/>
Value VARCHAR(255) NOT NULL,<br/>
PRIMARY KEY (id),<br/>
INDEX (machine)<br/>
</ul>);

<?php

	exit();
	
?>