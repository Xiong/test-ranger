#!/run/bin/perl
#       hash-key.pl
#       = Copyright 2011 Xiong Changnian <xiong@cpan.org> =
#       = Free Software = Artistic License 2.0 = NO WARRANTY =

use 5.010001;
use strict;
use warnings;

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
use Devel::Comments '###', '####';

#

my $hashref    = {
    _bomb   => 'Everybody get back.',
};

say STDERR $hashref->{_bomb};


__DATA__

Output: 


__END__
