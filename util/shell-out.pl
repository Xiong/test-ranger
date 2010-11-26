#!/run/bin/perl
#       #
#       = Copyright 2010 Xiong Changnian <xiong@cpan.org> =
#       = Free Software = Artistic License 2.0 = NO WARRANTY =

use strict;
use warnings;

#~ use Readonly;
#~ use feature qw(switch say state);
#~ use Perl6::Junction qw( all any none one );
#~ use List::Util qw(first max maxstr min minstr reduce shuffle sum);
#~ use File::Spec;
#~ use File::Spec::Functions qw(
#~     catdir
#~     catfile
#~     catpath
#~     splitpath
#~     curdir
#~     rootdir
#~     updir
#~     canonpath
#~ );
#~ use Cwd;
#~ use Smart::Comments '###', '####';

#

my $file = '/home/xiong/projects/comments/t/stok-62599/73-DC_ENV_1.t';
my @command = @ARGV;
push @command, $file;
my $command = join q{ }, @command;
exec $command;

exit(0);

__END__
