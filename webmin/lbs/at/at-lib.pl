# at-lib.pl
# Functions for listing and creating at jobs

do '../../web-lib.pl';
$gconfig{'overlang'} = "at_lang";
&init_config();

do "./linux-lib.pl";

# wrap_lines(text, width)
# Given a multi-line string, return an array of lines wrapped to
# the given width
sub wrap_lines
{
local @rv;
local $w = $_[1];
foreach $rest (split(/\n/, $_[0])) {
	if ($rest =~ /\S/) {
		while(length($rest) > $w) {
			push(@rv, substr($rest, 0, $w));
			$rest = substr($rest, $w);
			}
		push(@rv, $rest);
		}
	else {
		# Empty line .. keep as it is
		push(@rv, $rest);
		}
	}
return @rv;
}

# can_edit_user(&access, user)
sub can_edit_user
{
local %umap;
map { $umap{$_}++; } split(/\s+/, $_[0]->{'users'});
if ($_[0]->{'mode'} == 1 && !$umap{$_[1]} ||
    $_[0]->{'mode'} == 2 && $umap{$_[1]}) { return 0; }
elsif ($_[0]->{'mode'} == 3) {
	return $remote_user eq $_[1];
	}
else {
	return 1;
	}
}

1;

