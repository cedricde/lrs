<?php
#
# Linbox Rescue Server
# Copyright (C) 2005  Linbox FAS
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

/** 
 * This file content all constants of LSC module
 */

/**
 * Constants to define database tables names
 */
define("COMMANDS_TABLE", "commands");		/** Constant to define "Commands" table name */
define("COMMANDS_ON_HOST_TABLE", "commands_on_host"); /** Constant to define "Commands on host" table name */
define("COMMANDS_HISTORY_TABLE", "commands_history"); /** Constant to define "Commands history" table name */

/**
 * Constants to define the filenames and path to external library
 */
define("PHPLIB_PATH", "../../lbs_common/php/phplib/");  /** Define relative path to phplib */
define("PHPLIB_DB_API", "db_mysql.inc"); 		/** Define the phplib database API file */

/**
 * @name Constants to define the database access
 */

/** @{ */

define("DB_HOST", "localhost");				/** Define host of database */
define("DB_DATABASE_NAME", "lsc");			/** Define the database name */
define("DB_USER", "lrs");				/** Define the username database access */
define("DB_PASSWORD", "lrs");				/** Define the password of username */

/** @} */

/**
 * Constant to define the list of command states
 */
$COMMAND_STATES_LIST = array(
	"upload_in_progress",
	"upload_done",
	"upload_failed",
	"execution_in_progress",
	"execution_done",
	"execution_failed",
	"delete_in_progress",
	"delete_done",
	"delete_failed",
	"not_reachable",
	"done",
	"pause",
	"stop",
	"scheduled"
);

/**
 * Constant to define the uploaded, executed and deleted list of values
 */
$UPLOADED_EXECUTED_DELETED_LIST = array(
	"TODO",
	"IGNORED",
	"FAILED",
	"WORK_IN_PROGRESS",
	"DONE"
);

define("CYGWIN_WINDOWS_ROOT_PATH", "/cygdrive");

/**
 * @name Constant used by ssh.inc.php
 */

/** @{ */

define("STDERR_SEPARATOR", "#STDERR#"); /** STDERR string separator between the commands */
define("STDOUT_SEPARATOR", "#STDOUT#"); /** STDOUT string separator between the commands */
define("MOUNT_EXPLORER", "/var/autofs/ssh/"); /** all mounted FS are here */

/** @} */

define("WINDOWS_SEPARATOR", "\\");
define("LINUX_SEPARATOR", "/");
define("S_IFDIR", 040000);
define("MIME_UNKNOWN", "Unknown");
define("MIME_UNKNOWN_ICON", "unknown.png");
define("MIME_DIR", "Directory");
define("MIME_DIR_ICON", "folder.png");
define("DEFAULT_MIME", "application/octet-stream");
define("EXTICONSFILE", realpath(dirname(__FILE__)."/../extension.icons"));

/**
 * Define repository home directory
 */
$repository_home_directory = "/tftpboot/revoboot/lsc/";

define("MAX_COMMAND_LAUNCHER_PROCESSUS", 30);

define("MAX_LOG_SIZE", 100*1000); // octet
?>
