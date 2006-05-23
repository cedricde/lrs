<?php

include_once($INCLUDE_PATH .'Drivers/Driver.php');
include_once($INCLUDE_PATH .'Drivers/Sql/SqlFactory.php');
include_once($INCLUDE_PATH .'Components/Inventory.php');

/**
 * The SqlDriver class is a Driver-derivated class aiming at reading data from any database supported by the PHPLib.
 * 
 * @author Maxime Wojtczak (Linbox FAS)
 */
class SqlDriver extends Driver
{
	var $m_Connection;
	var $m_CachedFields;
	var $m_CachedQueries;
	var $m_CachedMachines;
	var $m_Tables;
	var $m_TodayInventory;
	var $m_LatestMachineInventory;
	var $m_DefinedCustomFields;
	var $m_InvIdDate;
	var $m_InvIdTime;

	/**
	 * Constructor. Build a SqlDriver object.
	 * 
	 * @param source The source name for which the current driver has been created.
	 * @param parameters An array containing informations used for the creation of the database connection. 
	 */
	function SqlDriver($source, $parameters)
	{
		parent::Driver($source);

		$this->m_Connection = & SqlFactory::getInstance( $parameters['Type'] , $parameters['Host'] , $parameters['Database'] , $parameters['Username'] , $parameters['Password'] );
		$this->m_CachedFields = array();
		$this->m_CachedQueries = array();
		$this->m_CachedMachines = array();
		$this->m_LatestMachineInventory = array();
	}

	/**
	 * Writes objects in the database.
	 * 
	 * @param objects An array containing all objects to store.
	 */
	function write(&$objects)
	{

		if ( ! $this->m_InvIdDate) {
			$todayinventory = new Inventory();
		} else {
			// hack used by transfer.php to make sure that an inventory has the same
			// Id for all object types
			$todayinventory = new Inventory($this->m_InvIdDate, $this->m_InvIdTime);
		}
		$this->m_InvIdDate = $todayinventory->getDate();
		$this->m_InvIdTime = $todayinventory->getTime();

		// For all objects to write
		foreach ($objects as $object)
		{
			$ismachine = $object->getClassName()=='machine';

			if ($object->getClassName() == "object") continue;

			// Get object and machine IDs in the database
			$objectid = $this->getObjectId(&$object);
			debug("Object ID : $objectid");
			
			
			if ( $ismachine )

				$this->saveCustomFields($object);	// obsolete ?

			else
			{
				$machine = & $object->getHost();
				$machineid = $this->getObjectId(&$machine);
				debug("Machine ID : $machineid");
				
				$inventoryid = $this->getObjectId(&$todayinventory);
				debug("Inventory ID : $inventoryid");

				$table = $this->getTableForClass( $object->getClassName() );

				// If there is no table where to store data
				if ( empty($table) )

					// Exit method
					return;

				// Store the correspondances between machines, inventory and components
				$sql = sprintf("REPLACE INTO %s VALUES ('%d','%d','%d');", "has$table", $machineid, $inventoryid, $objectid);
				debug($sql. "\n");

				$this->m_Connection->query($sql);

				$this->databaseCleanup($table, $inventoryid, $machineid);
				
				$this->updateLastId($table, $inventoryid, $machineid);

			}

		}

	}

	/**
	 * Remove old data from the table 
	 *
	 * @param table
	 * @param inventoryid
	 * @param machineid
	 */
	function databaseCleanup($table, $inventoryid, $machineid)
	{
		// Only keep the latest 100 inventories
		$keep = 100;
		
		// This cleanup should be done sometimes... (randomly or cron job? I don't like cron jobs)
		if (rand() % $keep != 0) return;
		
		// Orphaned entries in $table and in 'Inventory' should be removed !!
		// get the inv id of the last 100th inventory
		$sql = "SELECT DISTINCT inventory from has$table where machine=$machineid order by inventory desc limit $keep,1;";
		debug($sql);
		$this->m_Connection->query($sql);
		$this->m_Connection->next_record();
		$inventoryid = $this->m_Connection->Record['inventory'];
		if ( $inventoryid == "" ) return;

		$sql = "DELETE FROM has$table WHERE inventory<='". $inventoryid ."' AND machine=$machineid ;";
		debug($sql);
		$this->m_Connection->query($sql);

		// find orphaned entries. Use a LEFT JOIN.
		$sql = "DELETE $table from $table h LEFT JOIN has$table has ON h.id=has.$table WHERE has.$table IS NULL;";
		debug($sql);
		$this->m_Connection->query($sql);

		// TODO: remove entries in 'Inventory'
	
	} 	

	/**
	 * Update the last inventory ids in the Machine table to quickly find it later
	 *
	 * @param table
	 * @param inventoryid
	 * @param machineid
	 */
	function updateLastId($table, $inventoryid, $machineid)
	{
		$lfield = "lastId";
		if (strpos($table, "Boot") === 0) {
			$lfield = "lastBootId";
		} else if (strpos($table, "Custom") === 0) {
			$lfield = "lastCustomId";
		} else if (strpos($table, "Nmap") === 0) {
			$lfield = "lastNmapId";
		}
		$sql = "UPDATE Machine SET $lfield=$inventoryid WHERE id=$machineid;";
		debug($sql);
		$this->m_Connection->query($sql);		
	}
	/**
	 * Save the machine custom fields in the database.
	 * 
	 * @param machine The machine containing the fields to save.
	 */
	function saveCustomFields(&$machine)
	{
		$machineid = $this->getObjectId($machine);
			
		$connection = $this->m_Connection;

		// Retrieve the defined custom fields
		if ( empty( $this->m_DefinedCustomFields ) )
		{
			$sql = 'SELECT DISTINCT Field FROM CustomField;';
			debug($sql);

			$connection->query($sql);

			while ( $connection->next_record() )
			{
				$this->m_DefinedCustomFields[$connection->Record['Field']] = 1;
			}
		}
		
		// Retrieve the existing fields
		$sql = 'SELECT id,Field FROM CustomField WHERE machine=\''. $machineid .'\';';
		debug($sql);
		
		$connection->query($sql);
		
		$existingfields = array();
		$todelete = $this->m_DefinedCustomFields;
		
		while ( $connection->next_record() )

			$existingfields[ $connection->Record['Field'] ] = $connection->Record['id'];
			
		$customfields = & $machine->getCustomFields();
	
		foreach ( $customfields as $field => $value )
		{
			// If the current custom field exists
			if ( array_key_exists($field, $existingfields) )
			{
				// Update it if there is a non-blank value
				if ( !empty($value) )
				{
					$customfieldid = $existingfields[$field];
					$sql = 'UPDATE CustomField SET Value=\''. addslashes($value) .'\' WHERE id=\''. $customfieldid .'\';';
					unset($existingfields[$field]);
				}
			}
			else
				// Insert it
				$sql = 'INSERT INTO CustomField (machine,Field,Value) VALUES (\''. addslashes($machineid) .'\',\''. addslashes($field) .'\',\''. addslashes($value) .'\');';
				
			debug($sql);

			$connection->query($sql);

			unset($todelete[$field]);
		}

		
		// If there is custom fields not updated
		if ( !empty($existingfields) )
		{
			// They have to be deleted
			$sql = 'DELETE FROM CustomField WHERE id IN (\'';
			$sql .= join("','", array_values($existingfields) );
			$sql .= '\');';
			debug($sql);
			
			$connection->query($sql);
		}

		// If there is fields to delete for all machines
		if ( !empty($todelete) )
		{
			// They have to be deleted
			$sql = 'DELETE FROM CustomField WHERE Field IN (\'';
			$sql .= join("','", array_keys($todelete) );
			$sql .= '\');';
			debug($sql);
			
			$connection->query($sql);
		}

	}
	
	/**
	 * Gets the ID corresponding, in the database, with the object given in paramaeter. If the object doesn't exist, then it could be created.
	 * 
	 * @param object The object to retrieve the ID.
	 * @param create Tells if the object should be created if it doesn't exist.
	 * @return The object ID.
	 */
	function getObjectId(&$object,$create=true)
	{
		debug('Call to SqlDriver::getObjectId');

		$cachekey = $this->getCacheKey($object);

		// Look up in the cached queries if this search hasn't been yet performed.
		if ( array_key_exists($cachekey, $this->m_CachedQueries) )
			return $this->m_CachedQueries[$cachekey];
			
		$connection = $this->m_Connection;

		// If not, then execute the query
		$sql = 'SELECT id FROM '. $cachekey .';';
		debug($sql);

		$connection->query($sql);

		// If there is a corresponding object (at least one line)
		while ( $connection->next_record() )
		{
			// Get the ID
			$id = $connection->Record['id'];

			// Cache the query
			$this->m_CachedQueries[$cachekey] = $id;

			// Bye bye
			return $id;
		}
		
		// Else, if it should be created
		if ( $create )
		{
			$properties = $object->getProperties();
			
			$fields = '';
			$values = '';
			$first = true;

			// Get the table name
			$table = $this->getTableForClass( $object->getClassName() );

			$tablefields = & $this->getFields($table);
			
			// Get all the object properties
			foreach ($properties as $property => $value)
			{					
				// Except unused and host fields
				if ( $value!="" && $property!='Host' && $property!='Unused' && array_key_exists($property,$tablefields) )
				{
					// Mix them in a INSERT INTO friendly format
					$fields .= ',' . $property;
					$values .= ',\'' . addslashes($value) . '\'';
					
					$first = false;
				}
			}

			// Insert it
			$sql = 'INSERT INTO '. $table .' (id'. $fields .') VALUES (\'\''. $values .');';
			debug($sql);
			
			$connection->query($sql);
	
			// Retrieve the last insert id.
			$sql = 'SELECT MAX(id) AS \'id\' FROM '. addslashes($table) .';';
			debug($sql);
			
			$connection->query($sql);
			$connection->next_record();
	
			$id = $connection->Record['id'];

			// Cache the just-inserted query
			$this->m_CachedQueries[$cachekey] = $id;
	
			return $id;
		}
		else
		
			return 0;
	}
	
	/**
	 * Gets the object of a given type agree to the given ID.
	 * 
	 * @param type The type of object to retrieve.
	 * @param id The ID of object to get.
	 * @return An object.
	 */
	function getIdObject($type,$id)
	{
		// Get the table name
		$table = $this->getTableForClass( $type );
		
		$sql = 'SELECT * FROM '. $table .' WHERE id=\''. $id .'\';';
		
		$connection = $this->m_Connection;
		
		$connection->query($sql);
		
		$object = new $type();
		
		while ( $connection->next_record() )
		
			foreach ( $connection->Record as $parameter => $value )

			// Because the cols are presents twice, only consider the full-name record fields.
			// and omit thes id column.
			if ( ! is_numeric($parameter) && $parameter!='id')
				// Set the property
				$object->setProperty($parameter, $value);

		return $object;
	}
	
	/**
	 * Creates the key corresponding to an object than can be used for the cached queries. The format of this cache key is the same as the sql WHERE clause, so it can be used directly in SQL statements.
	 * 
	 * @param object The object to create key.
	 * @return A string in a WHERE clause format.
	 */
	function getCacheKey(&$object)
	{
		// Get the table name
		$table = $this->getTableForClass( $object->getClassName() );

		$tablefields = & $this->getFields($table);
		
		$clauses = array();

		// Create the WHERE directive agree to the table fields and object parameter values.
		foreach ( $tablefields as $name => $description )
		{
			if ( $name!='id' )
			{
				$clause = $name;

				$value = $object->getProperty($name);

				if ( $value != "" )
					$clause .= '=\''. addslashes( $this->truncateFieldValue($table, $name, $value) ) .'\'';

				else
					$clause .= ' IS NULL';
					
				$clauses[] = $clause;
			}
		}

		$where = join(' AND ', $clauses);
		
		return $table .' WHERE '. $where;
	}
	
	/**
	 * Adds a entry in the cached query table.
	 * 
	 * @param cachekey The cache key corresponding to an object.
	 * @param id The ID in the database of this object.
	 */
	function cacheQuery($cachekey, $id)
	{
		$this->m_CachedQueries[$cachekey] = $id;
	}
	
	function cacheMachine($id, &$machine)
	{
		debug('SqlDriver::cacheMachine');
		$this->m_CachedMachines[$id] = &$machine;
		
		$cachekey = $this->getCacheKey(&$machine);
		$this->cacheQuery($cachekey, $id);
	}
	
	function & getCachedMachine($id)
	{
		debug('Call to SqlDriver::getCachedMachine');

		if ( ! array_key_exists($id, $this->m_CachedMachines) )

			$this->m_CachedMachines[$id] = & $this->getIdObject('Machine', $id);
		
		return $this->m_CachedMachines[$id];
	}
	
	/**
	 * Returns the different fields of a given table.
	 * 
	 * @param table The table name to get the fields.
	 * @return An array contining all the table fields.
	 */
	function & getFields($table)
	{
		// if fields hasn't been yet cached
		if ( ! array_key_exists($table, $this->m_CachedFields) )
		{
			$fields = array();
			$connection = $this->m_Connection;

			// request fields
			// does it work for postgres ?
			$sql = 'DESC '. addslashes($table) .';';
			$connection->query($sql);

			$this->m_CachedFields[$table] = array();

			// and cache them
			while ( $field=$connection->next_record() )
			{
				$fieldname = $connection->Record['Field'];
				
				// hack to ignore modifications of Ids in Machine
				if (($table == "Machine") && (($fieldname == "lastId") 
					|| ($fieldname == "lastBootId") || ($fieldname == "lastCustomId") 
					|| ($fieldname == "lastNmapId"))) continue;
					
				
				$fields[$fieldname] = array();
				$fields[$fieldname]['Type'] =  $connection->Record['Type'];
				
				if ( eregi("varchar[^0-9]*([0-9]+)", $connection->Record['Type'], $matches) )
					
					$fields[$fieldname]['Length'] = $matches[1];

				else

					$fields[$fieldname]['Length'] = -1;
			}

			$this->m_CachedFields[$table] = & $fields;
		}

		return $this->m_CachedFields[$table];
	}
	
	/**
	 * Returns the length of a given field.
	 * 
	 * @param table The table of the field.
	 * @param field The field name.
	 * @return The field length.
	 */
	function getFieldLength($table, $field)
	{
		$fields = & $this->getFields($table);

		if ( isset($fields[$field]['Length']) )
		
			return $fields[$field]['Length'];
			
		else
		
			return -1;
	}
	
	/**
	 * Truncate the value in case of it is too long for the database field.
	 * 
	 * @param table The table where the value will be insert.
	 * @param field The field name in the table.
	 * @param value The value that will be insert.
	 * @return The truncated value.
	 */
	function truncateFieldValue($table, $field, $value)
	{
		$length = $this->getFieldLength($table, $field);

		// If the field is too long
		if ( $length!=-1 && strlen($value)>$length )
		
			// Return the value as-is
			$value = substr($value, 0, $length);

		return $value;
	}
	
	/**
	 * Return the corresponding table name of a class name. This function perform a CASE INSENSITIVE search.
	 * 
	 * @param class The class name or an Object-derivated object.
	 * @return The table associated to the class.
	 */
	function getTableForClass(&$class)
	{
		// If the parameter is an object
		if ( is_object($class) )
			// Get the class name
			$class = $class->getClassName();

		// If table name cache hasn't been created
		if ( !isset($this->m_Table) )
		{
			// Create it
			$this->m_Tables = array();
	
			// Get all the table informations
			$tables = $this->m_Connection->table_names();
	
			// Fill the cache
			foreach ($tables as $table)
			{
				$tablename = $table['table_name'];
				$this->m_Tables[ strtolower($tablename) ] = $tablename;
			}
		}

		return $this->m_Tables[ strtolower($class) ];
	}

	function & readMachineToTable($machines='', $inventory='')
	{
		debug('SqlDriver::readMachineToTable');

		global $datasource;
		$datasource->loadComponentClass('Machine');
		
		$connection = $this->m_Connection;

		// If there is a filter to apply (specific machines to retrieve)
		if ( is_array($machines) && count($machines)>0 )
		{
			$macaddresses = array();
			$machinenames = array();

			// put all filter clauses in a array agree to their types
			foreach ( $machines as $machine ) {
				// special keyword to get all hosts in the main page
				if ( $machine == "*ALL*") 
					$getall = 1;
				// if it is a MAC address
				if ( eregi('^[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}$', $machine) )
					$macaddresses[] = $machine;
				else
					$machinenames[] = $machine;
			}
		}

		// If there is mac addresses
		if ( !empty($macaddresses) )
		{
			// Looking for latest mac addresses attributions

			// Base query
			$sql = 'SELECT n.id,hn.machine FROM Network n, Inventory i, hasNetwork hn
				WHERE hn.network=n.id AND i.id=hn.inventory AND ';

			// Only select informations of the given inventory
			if ( !empty($inventory) )			
				$sql .= ' i.date<=\''. $inventory .'\' AND';
				
			// Select only given mac addresses
			$sql .= ' n.MACAddress IN (\''. join('\',\'', $macaddresses) .'\')';
			
			$sql .= ' GROUP BY hn.machine ORDER BY n.id ASC,hn.inventory DESC;';
			
			debug($sql);
			
			$connection->query($sql);
			
			$machineids = array();
			$currentid = '';
			
			while ( $connection->next_record() )
			{
				// If the network card hasn't been met until know
				if ( $connection->Record['id']!=$currentid )
				{
					$currentid = $connection->Record['id'];
					$machineids[] = $connection->Record['machine'];
				}
				// Else the card has already been met, so mac address attribution comes from a previous inventory
			}

		}

		// And finally, retrieve the machines themselves

		$sql = 'SELECT m.* as \'latestinventory\' FROM Machine m ';
			
		$clauses = array();

		// If no machines
		if ( empty($machines) || $getall == 1 ) {
			// Select all machines
			$clauses[] = ' 1';
		}
		else
		{

			// If no machine corresponding to paramaters were found
			if ( empty($machineids) && empty($machinenames) )

				// Return an empty array
				return array();

			// Build where clauses
			if ( !empty($machineids) )
	
				$clauses[] = ' m.id IN (\''. join('\',\'', $machineids) .'\')';
				
			if ( !empty($machinenames) )
	
				$clauses[] = ' m.Name IN (\''. join('\',\'', $machinenames) .'\')';
		}
		
		// If there is where clauses to add
		if ( !empty($clauses) )
		{
			// Then format them
			
			$sql .= ' WHERE ('. join(' OR ', $clauses) .')';
		}
		
		$sql .= ' GROUP BY m.id ORDER BY m.Name;';
		
		debug($sql);
		
		$connection->query($sql);
		
		$machines = array();
		
		// Put all machines in an array
		while ( $connection->next_record() )
		{
			unset($machine);
			$machine = new Machine();
			$machine->setName( $connection->Record['Name'] );
			
			$this->cacheMachine( $connection->Record['id'], $machine );

			$machines[] = & $machine;
		}

		return $machines;
	}

	/**
	 * Reads components in the the database.
	 * 
	 * @param type The type of objects to read.
	 * @param machines Owners of the components
	 * @param inventory The inventory from which machine should be read.
	 * @return An array of objects.
	 */
	function & readComponentToTable($type, & $machines, $inventory='')
	{
		global $datasource;
		$datasource->loadComponentClass($type);

		for ( $i=0 ; $i<count($machines) ; $i++ )
		{
			$machine = & $machines[$i];

			$machine->m_Components[$type] = array();
			$machine->m_Properties[$inventory] = 1;
		}

		$connection = $this->m_Connection;

		// Find the latest inventory id
		if ( empty($inventory) )
			$inventory = date("Y-m-d", time());
		
		$table = $this->getTableForClass($type);

		// If there is no table corresponding to type
		if ( empty($table) )

			return array();

		$join = strtolower($table);

		// Select all fields of data table.
		$sql  = 'SELECT t.*,ht.machine AS \'machineid\',MAX(ht.inventory) AS \'inventoryid\',MIN(i.Date) as \'firstappartion\' ';
		$sql .= 'FROM has'. $table .' ht ';
		$sql .= 'JOIN '. $table .' t ON ht.'. $join .'=t.id ';
		$sql .= 'JOIN Inventory i ON i.id=ht.inventory ';

		// Get all the machine ids
		$machineids = $this->getMachineIds($machines);

		if ( !empty($machineids) )
			$sql .= "WHERE ht.machine IN ('". join("','", $machineids) ."') ";
		else
			$sql .= "WHERE 1 ";

		// If an inventory date has been provided, then only select informations from this inventory
		if ( ! empty($inventory) )
			$sql .= 'AND i.date<=\''. $inventory .'\' ';

		$sql .= "GROUP BY t.id,ht.machine ";
		$sql .= "ORDER BY ht.machine, inventoryid DESC,ht.inventory;";

		debug($sql);
		
		$connection->query($sql);

		$currentmachine = '';
		$currentinventory = '';
		
		$objects = array();
		$idtoobject = array();

		$ignoredparameters = array('inventoryid', 'firstappartion', 'id', 'machineid');

		// for each object to read
		while ( $connection->next_record() )
		{
			// Check if it is a new machine
			if ( $currentmachine!=$connection->Record['machineid'] )
			{
				unset($host);

				$currentmachine = $connection->Record['machineid'];
				$currentinventory= $connection->Record['inventoryid'];

				// Perform some cache operations
				$host = & $this->getCachedMachine($currentmachine);
			}

			if ( $connection->Record['inventoryid']==$currentinventory )
			{
				$objectid = $connection->Record['id'];
	
				$object = new $type;
	
				// Update host<=>component link
				$object->setHost($host);
				$host->m_Components[$type][] = & $object;

				$idtoobject[$objectid] = & $object;

				// Fill fields
				foreach ( $connection->Record as $parameter => $value ) {
					// Because the cols are presents twice, only consider the full-name record fields.
					// and omit the id columns.
					if ( ! is_numeric($parameter) && ! in_array($parameter, $ignoredparameters) )
						// Set the property
						$object->setProperty($parameter, $value);
				}

				if ( !empty($connection->Record['firstappartion']) )

					$object->setFirstApparition( $connection->Record['firstappartion'] );

				$objects[] = & $object;

				unset($object);
			}
		}
		
		return $objects;
	}

	/**
	 * Return an array containing the database ids corresponding to given machines.
	 * 
	 * @param machines Machine objects.
	 * @return An array of IDs.
	 */
	function getMachineIds(&$machines)
	{
		$machineids = array();

		for ( $i=0 ; $i<count($machines) ; $i++ )
		{
			$machine = & $machines[$i];

			$machineids[] = $this->getObjectId($machine, false);
		}
		
		return $machineids;
	}

	/**
	 * Returns the ID of the latest Inventory at a given date.
	 * If no date is given, then the latest inventory id will be returned.
	 * BROKEN FUNCTION ! 
	 *
	 * @param date Date.
	 * @return The id corresponding to the inventory.
	 */
	function getLatestInventory($date='', $machineid='')
	{
		$connection = $this->m_Connection;
		
		$sql = 'SELECT MAX(id) as \'latest\' FROM Inventory';
		
		if ( !empty($date) )

			$sql .= ' WHERE Date<=\''.$date .'\'';
			
		$sql .= ' AND machine=$machineid;'; // BROKEN

		$connection->query($sql);

		$connection->next_record();

		if ( !empty($connection->Record['latest']) )
		
			return $connection->Record['latest'];
			
		else

			return 0;

	}
	
	/**
	 * Reads all the custom fields of the given machine. Custom fields are both retrieved and filled into the machine object.
	 * 
	 * @param machine The machine to get the custom fields.
	 *
	 * @return The custom fields in an array.
	 */	
	function & readCustomFields(&$machine)
	{
		$connection = $this->m_Connection;

		// Retrieve defined custom fields
		if ( empty( $this->m_DefinedCustomFields ) )
		{
			$sql = 'SELECT DISTINCT Field FROM CustomField;';
			debug($sql);

			$connection->query($sql);

			while ( $connection->next_record() )
			{
				$this->m_DefinedCustomFields[$connection->Record['Field']] = 1;
			}
		}

		$machine->m_CustomFields = array();
		
		if (defined($this->m_DefinedCustomFields)) {
			foreach ($this->m_DefinedCustomFields as $customfield => $exists)
			{
				$machine->m_CustomFields[$customfield] = '';
			}
		}

		$machineid = $this->getObjectId($machine);

		$sql = 'SELECT * FROM CustomField WHERE machine=\''. $machineid .'\' ORDER BY Field;';
		debug($sql);

		$connection->query($sql);

		while ( $connection->next_record() )

			$machine->m_CustomFields[ $connection->Record['Field'] ] = $connection->Record['Value'];

		return $machine->m_CustomFields;
	}

	/**
	 * Gets the connection through the driver is performing queries.
	 * 
	 * @return A PHPLib DB_Sql object.
	 */
	function & getConnection()
	{
		return $this->m_Connection;
	}
	
	/**
	 * Explicitely sets the connection.
	 * 
	 * @param connection The new connection to set.
	 */
	function setConnection( &$connection )
	{
		$this->m_Connection = & $connection;
	}
	
	/**
	 * Returns the date on which the component has appeared.
	 * 
	 * @param type Type of the object to retrieve the apparition date.
	 * @param machineid The machine id hosting the component.
	 * @param componentid The component ID.
	 * @return The apparition date (YYYY-MM-DD)
	 */
	function getApparitionDate($type, $machineid, $componentid)
	{
		$connection = $this->m_Connection;
		
		$table = $this->getTableForClass($type);
		$join = strtolower($table);
		
		$sql  = "SELECT MIN(i.Date) AS 'Date' FROM has$table ht JOIN Inventory i ON i.id=ht.inventory ";
		$sql .= "WHERE ht.machine='$machineid' AND ht.$join='$componentid';";
		
		$connection->query($sql);

		$date = '';

		while ( $connection->next_record() )
		
			$date = $connection->Record['Date'];
			
		return $date;
	}
	
	/**
	 * Force the inventory Id for the write function
	 *
	 * @param datetimearray an array with two elements: the date, and the time of the inventory
	 */
	function setInvId($datetimearray)
	{
		if (empty($datetimearray)) {
			return;
		}
		$this->m_InvIdDate = $datetimearray[0];
		$this->m_InvIdTime = $datetimearray[1];
	} 

	/**
	 * Get the inventory Id of the last write call
	 *
	 * @return an array with two elements: the date, and the time of the inventory
	 */
	function getInvId()
	{
		$ret = array($this->m_InvIdDate, $this->m_InvIdTime);
		
		return $ret;
	} 

	/**
	 * Add a new field in the database
	 *
	 * @param name 
	 * @paran type
	 */
	function addCustomField($name, $type)
	{
		$newname = eregi_replace("[^0-9a-z-]", "_", $name);
		
		$sql = "ALTER TABLE Custom ADD $newname $type;"; 
		$this->m_Connection->query($sql);

	} 
	
	/**
	 * Get hosts which did not sent an inventory
	 *
	 * @param date
	 * @paran type
	 */
	function getNotReceived($date, $type)
	{
		$ret = array();
		$where = "Last${type}Id is NULL";
		if ($date <= 0) {
			$sql = "SELECT Name FROM Machine WHERE $where;"; 
		} else {
			$hastbl = "hasBootGeneral";
			if ($type == "") $hastbl = "hasHardware";
			$sql = "SELECT m.Name, TO_DAYS(NOW()) - TO_DAYS(MAX(i.Date)) as maxi, i.Date, i.Time
			FROM Machine m, $hastbl h, Inventory i WHERE
			h.Machine=m.Id AND h.Inventory=i.Id GROUP BY m.Name;";
		}
		$connection = $this->m_Connection;
		$connection->query($sql);
		while ( $connection->next_record() ) {
			if ($date <=0 || ($date > 0 && $connection->Record['maxi'] >= $date))
				$ret[] = array ( $connection->Record['Name'],
						 $connection->Record['Date'],
						 $connection->Record['Time']
						);
		
		}
		return $ret;
	} 
	

}

?>
