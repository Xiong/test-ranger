#!/run/bin/perl
#       play-regex.pl
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

BEGIN { my $log = 'play.log'; unlink $log; };   # if exists
use Devel::Comments '###', ({ -file => 'play.log' });

### play.log <now>

my @data        = (
    'abc',
    'ac',
    'ac',
    'anc',
    
    
);
my $line_count  = scalar @data;

for (@data) {
    my $text    = $_;
    my $poop    = parse($text);
    
    ### Start: $text
    ### Pass1: $poop
    
};

### Total: $line_count

exit(0);

#----------------------------------------------------------------------------#

sub parse {
    my $text = shift;
    
#~     my $bs          = qr/\x08/;
    my $bs          = q/\x08/;
    
    
#~     $text          =~ s/a/x/g;
#~     $text          =~ s/$bs/x/g;
#~     $text          =~ s/[\b]/x/g;
    
    # Deal with backspaces.
    $text          =~ s/[^($bs)](?R)?($bs)//g;
#~     $text          =~ s/[^(\b)](?R)?[\b]//g;
    
    
    
    
    return $text;
};

__DATA__

Output: 


__END__
