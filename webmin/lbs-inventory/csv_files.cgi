#! /var/lib/lrs/php
<?
#
# $Id$
#
# Linbox Rescue Server
# Copyright (C) 2005  Linbox FAS

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

include_once('lbs-inventory.php');

  # to know which directories contain CSV files
  include_once("./reception_agent/config.php");
  
  # Template creation

  $general = tmplInit(array("general" => "csvall.tpl"));

  #
  # search for the CSV files
  #
  $rootDir = $chemin_CSV;
  $ext = ".csv"; # extension of the files we are looking for

  $tab = giveTableWithFiles($chemin_CSV, $ext); # associative array with paths to CSV file
  		# $tab['BIOS'] => array("../../name1.csv", "../../name2.csv", ..)
		# $tab['Hardware'] => array("../../name1.csv", "../../name2.csv", ..)
		#  ...

  $tabNotFiltred = $tab; # a copy of array with all full paths to a CSV files
  
  #
  # Delete the $baseDir path from the paths in the $tab
  #
  foreach($tab as $key => $value)  {
    for ($i=0; $i<count($tab[$key]); $i++) $tab[$key][$i] = str_replace($baseDir, "", $tab[$key][$i]);
  }
  
  #
  # find the longest array in $tab 
  #
  $max = count($tab['AccesLog']);
  foreach($tab as $key => $value)  {
    $newMax = count($tab[$key]);
    if ($max < $newMax) $max = $newMax;
  }

  $general->set_block("general", "main_row1", "main_rows1");
  $general->set_block("general", "main_row2", "main_rows2");
  #
  # Fill the template with links to files
  #
  for($k = 0; $k < $max; $k++) {
    #
    # fill the arrays `$addr` and `$nam` with the proper links
    #
    foreach($tab as $key => $value) {
      $addr[$key] = $tab[$key][$k];
      $tmp = array_reverse(split('/',$addr[$key]));
      $addr[$key] = $tmp[1] . '/' . $tmp[0];
#      $nam[$key] = explode("/", $tab[$key][$k]);
      $nam[$key] = $tmp[0]; 
    }

    $general->set_var(array(
		      "BaseFiles" => "<a href=dl.cgi?path=/".$addr['REST'].">".$nam['REST']."</a><br>",
		      "AccesLog" => "<a href=dl.cgi?path=/".$addr['AccesLog'].">".$nam['AccesLog']."</a><br>",
		      "Application" => "<a href=dl.cgi?path=/".$addr['Application'].">".$nam['Application']."</a><br>",
		      "BIOS" => "<a href=dl.cgi?path=/".$addr['BIOS'].">".$nam['BIOS']."</a><br>",
		      "Drivers" => "<a href=dl.cgi?path=/".$addr['Drivers'].">".$nam['Drivers']."</a><br>",
		      "Graphics" => "<a href=dl.cgi?path=/".$addr['Graphics'].">".$nam['Graphics']."</a><br>"
		      ));
    $general->parse("main_rows1", "main_row1", true);

    $general->set_var(array(
      		      "Hardware" => "<a href=dl.cgi?path=/".$addr['Hardware'].">".$nam['Hardware']."</a><br>",
      		      "LogicalDrivers" => "<a href=dl.cgi?path=/".$addr['LogicalDrivers'].">".$nam['LogicalDrivers']."</a><br>",
      		      "Network" => "<a href=dl.cgi?path=/".$addr['Network'].">".$nam['Network']."</a><br>",
      		      "Printers" => "<a href=dl.cgi?path=/".$addr['Printers'].">".$nam['Printers']."</a><br>",
      		      "Results" => "<a href=dl.cgi?path=/".$addr['Results'].">".$nam['Results']."</a><br>"
		      ));
    $general->parse("main_rows2", "main_row2", true);

  }

  #----------------------------------------------------------------------------
  #
  # Create the concatenations
  #
  $general->set_block("general", "main_row3", "main_rows3"); # prepare a template
  
  $conDirName = "Concatenations";
  $conDir = "$chemin_CSV/$conDirName";
    
  $ether = searchEtherInOCS();
  $key = array_keys($ether); # get the ethernet addresses of all computrers
  sort($key);
  
  #
  # create a `Concatenations` directory for concatenation files
  #
  if(!is_dir($conDir)) {
    mkdir($conDir);
    chmod ($conDir, 0777);
  }
  
  #
  # deal with every computer that we have in our database
  #
  foreach ($key as $k) {
      $dublePointMac = addDublePoint($k);
      $nom_pc = MacToName($k);
         
      # concatenation file name of the present computer
      $file_con = "$nom_pc"."_con".$ext;
          
       # delete the old concatenation file and create a new one
	if (file_exists("$conDir/$file_con")) {
          unlink("$conDir/$file_con");
      }

      touch("$conDir/$file_con"); # create a new empty file 
      chmod ("$conDir/$file_con", 0666);

      # here we will place all lines found in a file
      $file_content = array();

      #
      # for each directory with CSV files (excluding the `Concatenations` dir)
      # find the CSV file with information concerning the present computer
      # and put them to the concatenation file
      #
      foreach($tab as $key2 => $value)  {
        if ($key2 != $conDirName)
          for ($i=0; $i<count($tab[$key2]); $i++)  {
            if(strstr($tab[$key2][$i], $nom_pc)) {
	      $file_content = file($tabNotFiltred[$key2][$i]); # put the lines of a file to the array
            
	      if (is_writable("$conDir/$file_con")) {
   	        if (!$handle = fopen("$conDir/$file_con", "a")) {
                  print "Cannot open file $conDir/$file_con";
    	        }
	     
		# put a nice separator to know from which file the information come from
	        $name = $tab[$key2][$i];
	        if (!fwrite($handle, "------------====== $name ======------------\n"))
          	  print "Cannot write to file ($conDir/$file_con)";
	     
	        # put every line to the concatenation file
	        for ($j = 0; $j < count($file_content); $j++) {
      	     	  if (!fwrite($handle, $file_content[$j]))
        	    print "Cannot write to file ($conDir/$file_con)";
    	        }
  	     	if (!fwrite($handle, "\n"))
        	  print "Cannot write to file ($conDir/$file_con)";
      
	         fclose($handle);	      

	      }
	      else {
		print "The file $filename is not writable";
	     }
          }
        } # END for ($i=0; $i<count($tab[$key2]); $i++)
      } # END foreach($tab as $key2 => $value)

      #
      # put everything into the template
      #
      $general->set_var(array(
      		      "Name" => $nom_pc,
      		      "ConcatenationFile" => "<a href=dl.cgi?path=/$conDirName/$file_con > $file_con</a><br>"
		      ));
      $general->parse("main_rows3", "main_row3", true);
      
  } # END foreach ($key as $k)

	# header
	echo perl_exec("./lbs_header.cgi", array("inventory csvfiles", $text{'index_title'}, "software"));

	$general->pparse("out", "general");

	# footer
	echo perl_exec("./lbs_footer.cgi");
?>
