#!/run/bin/perl
#       pack.pl
#       = Copyright 2010 Xiong Changnian <xiong@cpan.org>    =
#       = Free Software = Artistic License 2.0 = NO WARRANTY =

use strict;
use warnings;
use Carp;

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

# Announce thyself
say qq{# $0: Running...};

# Be sure user cd to a project folder under Git control
my $project_dirabs          = getcwd();
my $vcs_dirrel              = '.git';
my $vcs_dirabs              = catdir( $project_dirabs, $vcs_dirrel );
stat $vcs_dirabs or _crash('no_vcs');




######## INTERNAL UTILITY ########
#
#   _crash( $errkey, @parms );      # fatal out of internal error
#       
# Calls croak() with some message. 
#   
sub _crash {
    my $errkey      = $_[0];            # remaining args replace placeholders
    my $prepend     = $0;               # prepend to all errors
    my $intro       = q{# };            # introduce each line
       $prepend     = join q{}, $intro, $prepend, q{: };
    my $indent      = qq{\n} . $intro 
                    . q{ } x ( (length $prepend) - (length $intro) )
                    ;
    
    my @lines       ;
    my $text        ;
    
    # define errors
    my $error       = {
        no_vcs          => [ 
            'Not within a VCS controlled folder.', 
            'Suggest cd to top-level project folder and try again.', 
        ],
        
    };
    
    # find and expand error
    @lines          = @{ $error->{$errkey} };
    $text           = $prepend . join $indent, @lines;
    
    # now croak()
    croak $text;
    return 0;                   # should never get here, though
};

__DATA__

Output: 


__END__
