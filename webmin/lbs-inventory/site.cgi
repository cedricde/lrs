<?
#
# Ini parser
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

#
# Class for reading and writing configuration files. v 0.90. 
#
class ConfigFile {
  var $filename;
  var $dirty = 0;
  var $values = array();

  # constructor
  function ConfigFile ($name) {
    $this->filename = $name;
    $this->reload();
  }

  # reload a file
  function reload() 
  {
    if (!is_readable($this->filename)) die ("Error: $this->filename not readable");
    if (!($fd = fopen("$this->filename", "r"))) die ("Error: Cannot open ".$this->filename);
    $line = 0;
    $prog = "";

    while (!feof ($fd)) {
      $data = trim(fgets($fd, 1024));
      $line++;
      # discard all blank lines
      # comments can begin with a '#' or a ';'
      if (!(ereg("^#|^;|^[ \t]*$", $data))) {
	# parse the line to find a new section
	$data = ereg_replace("^\\[ *([^\[ ]+) *\\]$", "section=\\1", $data);
 	# parse the line to find the keyword and the value
	ereg("([a-zA-Z0-9_]+)[ \t]*=[ \t]*(.+)", $data, $regs);
	$key = strtolower($regs[1]);
	$val = trim($regs[2]);
	if ($key == "section") $prog = $val;
	else {
	  if ($prog == "") die ("Error: in configuration file $this->filename , line $line: missing section");
	  else $this->values[$prog.".".$key] = $val;
	}
      }
    }
    #var_dump($this->values);
    # data is in sync
    $this->dirty = 0;
  }

  #
  # Write a value to the local array and to the configuration file
  #
  function write($key, $value)
  {
    $value = trim($value);
    # check if it differs from the cached value
    if ($this->get($key) != "$value") {
      # split the key
      list($wsection, $wkey) = split ("\.", $key);
      # echo "@$wsection@$wkey@<br>";
      # write this to disk
      if (!is_writeable($this->filename)) { die ("Error: $this->filename not writeable"); }
      if (!($fd = fopen("$this->filename", "r"))) { die ("Error: Cannot open for reading ".$this->filename); }
      # read it
      $contents = fread ($fd, 10000);
      fclose($fd);
      # convert to array
      $arr = split("\n", $contents);
      
      $section = "";
      $sectionline = 0;
      $modified = 0;
      while (list ($line, $val) = each ($arr)) {
	if (ereg("^\\[ *([^\[ ]+) *\\]", $val, $regs)) {
	  # new section
	  $oldsection = $section;
	  $section = $regs[1];
	  #echo "new section:$section, old: $oldsection<br>";
	  if (($oldsection == $wsection) && ($section != $wsection)) {
	    # insert the value
	    $arr[$sectionline] = "[ $oldsection ]\n$wkey = $value";
	    $modified = 1;
	    break;
	  }
	  $sectionline = $line;
	  # not in the good section, skip
	  if ($wsection != $section) continue;
	}
 	# parse the line to find the keyword and the value
	if (ereg($wkey."[ \t]*=[ \t]*", trim($val), $regs)) {
	    # set the value
	    $arr[$line] = "$wkey = $value";
	    $modified = 1;
	    break;
	}
      }
      # add a new key to the last section
      if ((!$modified) && ($section == $wsection)) {
	$arr[$sectionline] = "[ $section ]\n$wkey = $value";
      }

      # overwrite
      if (!($fd = fopen("$this->filename", "w"))) {
	die ("Error: Cannot open for writing ".$this->filename);
      }
      fwrite($fd, join("\n", $arr));
      #echo "<pre>".var_dump($arr)."</pre>";
      #fwrite($fd, "\n");
      fclose ($fd);
      
    }
  }

  # Get a value
  function value($key) { return $this->values[$key];  }
  function get($key) { return $this->values[$key]; }

  # Set
  function set($key, $val) {
    $this->values[$key] = $val;
    # disk and memory not in sync
    $this->dirty = 1;
  }

  # Get Keys
  function keys() { return array_keys($this->values); }

  # Get the whole array
  function get_array() { return $this->values; }
}

?>
