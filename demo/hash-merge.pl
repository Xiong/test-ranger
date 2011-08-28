#!/run/bin/perl
#       hash-merge.pl
#       = Copyright 2011 Xiong Changnian <xiong@cpan.org> =
#       = Free Software = Artistic License 2.0 = NO WARRANTY =

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

my %A   = ( -one => 1, -foo => 'bar' );
my %B   = ( -two => 2, -foo => 'zaz' );
my %C   = ( %A, %B );

### %C

__DATA__

Output: 


__END__
