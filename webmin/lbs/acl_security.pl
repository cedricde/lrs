#!/usr/bin/perl

require './lbs-lib.pl';

sub acl_security_form
{
my ($chk_yes,$chk_no) ;

 if ($_[0]->{'modify'} == 0) { ($chk_yes,$chk_no) = ("checked", "") ;} 
 else { ($chk_yes,$chk_no) = ("", "checked") ;}

 print("<tr>",
  "<td><b>", $text{ 'acl_modify' }, "</b></td>",
  "<td>",
  "<input type=radio name=modify value=0 $chk_yes>", $text{ 'acl_yes' },
  " <input type=radio name=modify value=1 $chk_no>", $text{ 'acl_no' },
  "</td>",
  "</tr>" );
}

sub acl_security_save
{
    $_[0] -> { 'modify' } = $in{ 'modify' };
}

1;
