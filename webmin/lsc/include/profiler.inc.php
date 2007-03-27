<?php
/*
 * Linbox Rescue Server - Secure Remote Control Module
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

define("PROFILER_ENABLE", false);	/**< Enable or disable profiler */

if (PROFILER_ENABLE) {
	$profiler_array = array();
}

/**
 * @file This files provide some time measure functions
 */

function utime(){
	$time = microtime();
	return substr($time, 11, 10).substr($time, 1, 7);
}
 
function LSC_Profiler_Tag($tag_name)
{
	if (PROFILER_ENABLE) {
		global $profiler_array;

		array_push(
			$profiler_array,
			array(
				"tag_name" => $tag_name,
				"time" => utime()
			)
		);
	}
}

function LSC_Profiler_Display()
{
	if (PROFILER_ENABLE) {
		global $profiler_array;

		print(
"<table>
	<thead>
		<tr>
			<th>Tag name</th>
			<th>Time since first tag (in second)</th>
			<th>Time since last tag (in second)</th>
		</tr>
	</thead>
	<tbody>");

		$start_tag_time = 0;
		$last_tag_time = 0;
		foreach($profiler_array as $tag) {
			print(
"		<tr>");
			if ($start_tag_time == 0) {
				$start_tag_time = $tag["time"];
				$last_tag_time = $tag["time"];
				printf(
					"<td>%s</td><td>0</td><td>0</td>",
					$tag["tag_name"]
				);
			} else {
				$diff_start_tag = $tag["time"] - $start_tag_time;
				$diff_last_tag = $tag["time"] - $last_tag_time;
				printf(
					"<td>%s</td><td>%s</td><td>%s</td>",
					$tag["tag_name"],
					$diff_start_tag,
					$diff_last_tag
				);
				$last_tag_time = $tag["time"];
			}
			print(
"		</tr>");
		}

		print(
"	</tbody>
</table>");
	}
}

?>
