<?php
/*
 * Linbox Rescue Server - Secure Remote Control Module
 * Copyright (C) 2005	Linbox FAS
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA	02111-1307, USA.
 */

/**
 * @file file.inc.php
 *
 * Provide class to handle tree directory
 */

require_once(dirname(__FILE__) . "/directory.inc.php"); // Use LSC_Directory class

 
/**
 * LSC_Tree generate directory tree structure
 *
 * $tree member content the structure.
 *
 * <p><strong>Example :</strong></p>
 *
 * <pre>
 * lsc_tree Object
 * (
 *    [base_directory] => /home/
 *    [directory_to_walk] => /lsc/webmin/
 *    [directory_to_walk_splited_in_array] => Array
 *        (
 *            [0] => 
 *            [1] => lsc
 *            [2] => webmin
 *        )
 *
 *    [tree] => Array
 *        (
 *            [name] => 
 *            [is_subdirectory] => 1
 *            [path] => 
 *            [directory_list] => Array
 *                (
 *                    [0] => Array
 *                        (
 *                            [name] => lsc
 *                            [is_subdirectory] => 1
 *                            [path] => /lsc
 *                            [directory_list] => Array
 *                                (
 *                                    [0] => Array
 *                                        (
 *                                            [name] => .ssh
 *                                            [is_subdirectory] => 
 *                                            [path] => /lsc/.ssh
 *                                        )
 *                                    [1] => Array
 *                                        (
 *                                            [name] => .mc
 *                                            [is_subdirectory] => 
 *                                            [path] => /lsc/.mc
 *                                        )
 *                                    [2] => Array
 *                                        (
 *                                            [name] => webmin
 *                                            [is_subdirectory] => 1
 *                                            [path] => /lsc/webmin
 *                                            [directory_list] => Array
 *                                                (
 *                                                )
 *                                        )
 *                                    [3] => Array
 *                                        (
 *                                            [name] => .subversion
 *                                            [is_subdirectory] => 
 *                                            [path] => /lsc/.subversion
 *                                        )
 *                                     [4] => Array
 *                                        (
 *                                            [name] => database_mysql
 *                                            [is_subdirectory] => 
 *                                            [path] => /lsc/database_mysql
 *                                        )
 *                                     [5] => Array
 *                                        (
 *                                            [name] => repository
 *                                            [is_subdirectory] => 
 *                                            [path] => /lsc/repository
 *                                        )
 *                                )
 *                        )
 *               )
 *       )
 * )
 * </pre>
 */
class LSC_Tree
{
	var $base_directory;				/**< It's base directory not walk in it */
	var $directory_to_walk;				/**< Walk in this directory */
	var $directory_to_walk_splited_in_array;	/**< This member is used by make_tree method. It's directory_to_walk splited in array */
	var $tree;					/**> This content the tree generated */
	var $errors = 0;

	/**
	 * LSC_Tree class constructor
	 *
	 * @param $base_directory is the begin of path directory to tree making
	 * @param $directory_to_walk is the directory whose be walk
	 *
	 */
	function LSC_Tree($base_directory, $directory_to_walk)
	{ 
		debug(1, "Entering in LSC_Tree class");
		
		/*
		 * Test if base_directory exist
		 */
		exec("cd ".escapeshellarg("/".$base_directory));
		if (!file_exists("/".$base_directory)) {
			$this->errors++;
			return;
		}
		
		if (!is_dir("/".$base_directory)) {
			$this->errors++;
			return;
		}
		
		/*
		 *
		 */
		$this->base_directory = $base_directory;
		$this->directory_to_walk = $directory_to_walk;

		if ($this->directory_to_walk == "") $this->directory_to_walk = "/";

		$this->directory_to_walk_splited_in_array = split("/", $this->directory_to_walk);
		if ( $this->directory_to_walk_splited_in_array[count($this->directory_to_walk_splited_in_array)-1] == "" ) {
			array_pop($this->directory_to_walk_splited_in_array);
		}
		/*
		debug(2, sprintf(
			"%s - directory_to_walk_splited_in_array : %s",
			__FUNCTION__,
			var_export($this->directory_to_walk_splited_in_array, true)
		));*/

		$this->tree = $this->make_tree(0);

		/*
		debug(9, sprintf(
			"%s - tree = <pre>%s</pre>",
			__FUNCTION__,
			var_export($this->tree, true)
		));*/
	}

	/**
	 * This is recursive private method to generate tree directory
	 *
	 * @parm $level to walk
	 * @return tree array \n
	 * return false is some error
	 */
	function make_tree($level)
	{
		/*
		 * Control level isn't to big
		 */
		if ( $level >= count($this->directory_to_walk_splited_in_array) ) {
			debug(2, "make_tree error : level is too big");
			return false;
		}
		
		// Next directory name (used to don't always search information in directory_to_walk_splited_in_array)
		$next_directory_name = $this->directory_to_walk_splited_in_array[$level+1];
		
		/*
		 * Initialise some variables
		 */

		/*
		 * Build the current directory
		 */
		$current_directory_path = implode(
			"/", 
			array_slice($this->directory_to_walk_splited_in_array, 0, $level + 1 )
		);

		$base_and_current_directory_path = sprintf(
			"%s/%s",
			$this->base_directory,
			$current_directory_path
		);
		debug(2, sprintf("make_tree, the base and current directory path is : %s", $base_and_current_directory_path));
		
		/*
		 * Describe current directory
		 */
		if ($this->directory_to_walk_splited_in_array[$level] == "") {
			$directory_name = "/";
			$current_directory_path = "/";
		} else {
			$directory_name = $this->directory_to_walk_splited_in_array[$level];
		}
		
		$tree = array(
			"name" => $directory_name,
			"is_subdirectory" => true,
			"path" => $current_directory_path,
			"directory_list" => array()
		);

		
		
		/*
		 * Iterate all directory item of current directory (level)
		 */
		debug(2, sprintf("The next directory name is : %s", $next_directory_name));
		
		$current_directory = new LSC_Directory($base_and_current_directory_path);
		foreach($current_directory->get_directory_only() as $directory_item) {
			debug(2, 
				sprintf(
					"Iterate this item : %s",
					$directory_item["name"]					
				)
			);
			
			if ( $directory_item["name"] == $next_directory_name ) {
				debug(2, "Entry in subdirectory");
				// Item is in directory to walk
				if ( $level == (count($this->directory_to_walk_splited_in_array) - 1) ) {
					debug(2, "It's the last subdirectory, don't walk in it");
					// It's the last subdirectory, don't walk in it
					array_push(
						$tree["directory_list"],
						array(
							"name" => $directory_item["name"],
							"is_subdirectory" => true,
							"path" => clean_path($current_directory_path."/".$directory_item["name"]),
							"directory_list" => array()
						)
					);
				} else {
					debug(2, "Call make_tree (recursive) directory to catch subdirectory");
					// Call make_tree (recursive) directory to catch subdirectory
					array_push(
						$tree["directory_list"], 
						$this->make_tree($level + 1)
					);
				}
			} else {
				array_push(
					$tree["directory_list"],
					array(
						"name" => $directory_item["name"],
						"is_subdirectory" => false,
						"path" => clean_path($current_directory_path."/".$directory_item["name"])
					)
				);
			}
		}
		return $tree;
	}

	
	/**
	 * Display the tree in ASCII mode (to terminal)
	 *
	 * This function is useful to debuging
	 */
	function show_in_ascii()
	{
		printf(
			"Tree of this directory : base(%s) walk(%s)\n", 
			$this->base_directory, 
			$this->directory_to_walk
		);
		
		$this->show_in_ascii_recursive($this->tree);
	}

	/**
	 * Recusive display tree in ASCII mode, used by show_in_ascii method (private method)
	 *
	 * @param $tree is the tree or subtree to display
	 */
	function show_in_ascii_recursive(&$tree, $tabulation = "")
	{
		foreach($tree["directory_list"] as $item) {
			if ($item["is_subdirectory"]) {
				printf(
					"%s_%s_\n",
					$tabulation,
					$item["name"]
				);
				$this->show_in_ascii_recursive($item, $tabulation . "\t");
			} else {
				printf(
					"%s%s\n",
					$tabulation,
					$item["name"]
				);
			}
		}
	}

}

class LSC_Distant_Tree extends LSC_Tree
{
	var $session;			/**< LSC_Session class instance */

	function LSC_Distant_Tree($session, $base_directory, $directory_to_walk)
	{
		$this->session = $session;

		$this->LSC_Tree(
			clean_path(
				sprintf(
					"%s/%s/%s",
					$session->sshfs_mount,
					$session->root_path,
					$base_directory
				)
			),
			$directory_to_walk
		);
	}
}
?>
