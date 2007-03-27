<?php
/*
 * Linbox Rescue Server
 * Copyright (C) 2005  Linbox FAS
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

/**
 * DEBUG set current debug level
 */
$DEBUG=0;

/** 
 * OUTPUT_TYPE set current output type : "WEB" or "TERMINAL"
 */
$OUTPUT_TYPE="TERMINAL";

/**
 * Debug display function
 *
 * @param $level = if DEBUG constant is >= level then the message is printed
 * @param $message = message debug to print
 */
function debug($level, $message) {
	global $DEBUG, $OUTPUT_TYPE;

	if ($DEBUG >= $level) {
		if ($OUTPUT_TYPE == "TERMINAL") {
			printf("%s\n", $message);
		} elseif ($OUTPUT_TYPE == "WEB") {
			printf("%s<br />", $message);
		}
	}
}

?>
