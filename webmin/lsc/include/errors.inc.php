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
 * @file errors.inc.php
 * This file give all errors Constants and its 
 * traduction correspondance.
 *
 * When an error occurs, a error constant is set.
 * Then, You can use this constant to determine is
 * meaning in the current currant language you work.
 */
define("ERROR_INVALIDE_FILENAME", 1);
define("ERROR_INVALIDE_DIRNAME", 2);
define("ERROR_IS_NOT_FILE", 3);
define("ERROR_IS_NOT_DIRECTORY", 4);
define("ERROR_CREATE_FILE", 5);
define("ERROR_CREATE_DIRECTORY", 6);
define("ERROR_NOT_EXIST_FILE", 7);
define("ERROR_NOT_EXIST_DIRECTORY", 8);
define("ERROR_CAN_NOT_REMOVE_FILE", 9);
define("ERROR_CAN_NOT_REMOVE_DIRECTORY", 10);
define("ERROR_GET_ON_LOCAL_HOST", 11);
define("ERROR_RENAME_FILE", 12);
define("ERROR_REMOVE_FILE", 13);
define("ERROR_PERMISSION", 14);
define("ERROR_I_CAN_CHANGE_ATTRIBUTE_OF_FILE", 15);
define("ERROR_DIRECTORY_NAME_IS_EMPTY", 16);
define("ERROR_I_CAN_NOT_CREATE_DIRECTORY_IT_ALREADY_EXIST", 17);
define("ERROR_I_CAN_NOT_REMOVE_DIRECTORY_IT_DO_NOT_EXIST", 18);
define("ERROR_REMOVE_DIRECTORY", 19);
define("ERROR_I_CAN_NOT_EXECUTE_FILE", 20);
define("ERROR_FILE_TO_UPLOAD_NOT_EXIST", 21);
define("ERROR_I_CAN_NOT_UPLOAD_FILE", 22);
define("ERROR_CUSTOM", 42);
define("ERROR_UNKOWN", 4242);

$errors = array(
ERROR_INVALIDE_FILENAME => "err_invalide_filename",
ERROR_INVALIDE_DIRNAME => "err_invalide_dirname",
ERROR_IS_NOT_FILE => "err_isnt_file",
ERROR_IS_NOT_DIRECTORY => "err_isnt_dire",
ERROR_CREATE_FILE => "err_create_file",
ERROR_CREATE_DIRECTORY => "err_create_dir",
ERROR_NOT_EXIST_FILE => "err_not_exist_file",
ERROR_NOT_EXIST_DIRECTORY => "err_not_exist_dir",
ERROR_CAN_NOT_RM_FILE => "err_cant_rm_file",
ERROR_CAN_NOT_RM_DIR => "err_cant_rm_dir",
ERROR_PERMISSION => "err_perm",
ERROR_DEFAULT => "err_default");
?>
