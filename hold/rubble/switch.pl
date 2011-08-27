#!/run/bin/perl
#       switch.pl
#       = Copyright 2010 Xiong Changnian <xiong@cpan.org>    =
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

#~ my $t       = 3;
my $t       = 'foo';
my $p       ;

#~ $p  = eval {
#~     given ($t) {
#~         when (2) {42}
#~         when (3) {43}
#~         default {99}
#~     };
#~ };
#~ 
$p  = do{
    for ($t) {
        /foo/ and do{42; last};
        /bar/ and do{43; last};
    };
};

say $p;

__DATA__

Output: 


__END__
