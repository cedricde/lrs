#!/var/lib/lrs/php
<?php
#
# $Id$
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

	include_once('commons.php');
	include_once('filters.php');	

	// MAIN
	$datasource->loadComponentClass('Component');
	
	print perl_exec("./lbs_header.cgi", array("lrs-inventory general", $text{'title_gen'}, "general"));

	renderTable('BootGeneral', 'System.tpl', array(), null, 'FilterSplitPipe');
	renderTable('Hardware', 'OS.tpl' );

	renderTable('Custom', 'Warranty.tpl');
	renderTable('Custom', 'Location.tpl');

	print perl_exec("lbs_footer.cgi");

?>
