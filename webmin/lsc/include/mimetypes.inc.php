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
 * Load the mime types file
 *
 * @param $file is path to mimetype file
 * @param $icons return array values (return by reference)
 * @param $mimetypes return array values (return by reference)
 *
 * @return 0 if load mime type with success\n
 * return -1 if error.
 
 * <p><strong>Example :</strong></p>
 *
 * <pre>
 * $exticonsfile = "/etc/webmin/lsc/extension.icons";
 * $icons = array();
 * $mimetypes = array();
 * LSC_loadMime($exticonsfile, $icons, $mimetypes)."\n");
 * </pre>
 */
function LSC_load_mime_types($file, &$icons, &$mimetypes)
{
	if (($fd = @fopen($file, "r")) !== false) {
		while ( ($line = fgets($fd, 1024)) !== false ) {
			$line = trim($line);
			if (strlen($line) != 0 && $line{0} != "#") {
				list($ext, $mime, $icon) = preg_split("/[\s]+/", trim($line));
				if (strlen($icon) == 0) {
					$icon = $last;
				} else {
					$last = $icon;
				}

				if (isset($icons)) {
					$icons[$ext] = $icon;
				}

				if (isset($mimetypes)) {
					$mimetypes[$ext] = $mime;
				}
			}
		}
		fclose($fd);
	} else {
		return -1;
	}

	/*
	debug(9, sprintf(
		"%s - icons values : <pre>%s</pre>",
		__FUNCTION__,
		var_export($icons, true)
	));*/

	/*
	debug(9, sprintf(
		"%s - mimetypes values : <pre>%s</pre>",
		__FUNCTION__,
		var_export($mimetypes, true)
	));*/
	return 0;
}

/**
 * LSC_loadMime is used to compatibility with old code
 *
 * @param $file is path to mimetype file
 * @param $icons return array values (return by reference)
 * @param $mimetypes return array values (return by reference)
 *
 * @see LSC_load_mime_types
 */
function LSC_loadMime($file, &$icons, &$mimetypes)
{
	return LSC_load_mime_types($file, $icons, $mimetypes);
}

?>
