#!/run/bin/perl
#       trish.pl
#       = Copyright 2010 Xiong Changnian <xiong@cpan.org> =
#       = Free Software = Artistic License 2.0 = NO WARRANTY =

use strict;
use warnings;

use Test::Ranger::Shell;

#----------------------------------------------------------------------------#

Test::Ranger::Shell::main();

# It is better to die() than to return() in failure.
exit(0);

__END__


