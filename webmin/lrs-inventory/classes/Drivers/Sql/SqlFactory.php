<?php

/**
 * SqlFactory is used for creating database connections used by the SqlDriver.
 * 
 * @author Maxime Wojtczak (Linbox FAS)
 */
class SqlFactory
{
	/**
	 * Creates an instance of a PHPLib DB_Sql using the right driver.
	 * 
	 * @param type The type of the database driver to connect (mysql, oracle, pgsql)
	 * @param host The database hostname to connect.
	 * @param database The database to select.
	 * @param user The username to use.
	 * @param password The password to connect with.
	 * @return A DB_Sql derivated class.
	 */
	function getInstance($type,$host,$database,$user,$password)
	{
		global $INCLUDE_PATH;

		// Load the PHPLib database driver corresponding to the type given in parameter.
		$dbdriver = $INCLUDE_PATH .'../../lbs_common/php/phplib/db_'. $type .'.inc';
		include_once($dbdriver);
		
		// Then create the connection
		$sql = new DB_Sql();

		$sql->Host = $host;
		$sql->Database = $database;
		$sql->User = $user;
		$sql->Password = $password;

		return $sql;
	}
}

?>