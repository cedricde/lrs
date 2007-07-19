# acl_security_form(&options)
# Output HTML for editing security options for the useradmin module
sub acl_security_form
{
local $o = $_[0];

print "<tr> <td valign=top><b>Groupes autorisés (regexp)</b></td>\n";
print "<td colspan=3><input name=group_rx size=40 value='$o->{'group_rx'}'>\n";
print "</td> </tr>\n";
}

# acl_security_save(&options)
# Parse the form for security options for the useradmin module
sub acl_security_save
{
$_[0]->{'group_rx'} = $in{'group_rx'};
}

1;
