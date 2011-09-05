#!/run/bin/perl
#       parse-session.pl
#       = Copyright 2011 Xiong Changnian <xiong@cpan.org> =
#       = Free Software = Artistic License 2.0 = NO WARRANTY =

# Our goal is to parse a session file created by 'script'.

use strict;
use warnings;

use Readonly;
use feature qw(switch say state);
use Perl6::Junction qw( all any none one );
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use File::Spec;
use File::Spec::Functions qw(
    catdir
    catfile
    catpath
    splitpath
    curdir
    rootdir
    updir
    canonpath
);
use Cwd;
use Smart::Comments '###', '####';

#
my $session_file    = 'file/sample-session-01';
open my $fh, '<', $session_file
    or die "Couldn't open $session_file for reading ", $!;
while (<$fh>) {
    my $line        = $_;
    print $line;
    
};

close $fh;

__DATA__

Output: 


__END__
