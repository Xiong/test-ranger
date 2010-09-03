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
my $command                 ;

sub _talk;          # forward

# Announce thyself
_talk 'Running...';

# Be sure user cd to a project folder under Git control
my $project_dirabs      = getcwd();
my $project_dh          ;
my $vcs_dirrel          = '.git';
my $vcs_dirabs          = catdir( $project_dirabs, $vcs_dirrel );
stat $vcs_dirabs or _crash('no_vcs');

# Save any loose top-level files



# Copy top/ to ./
my $top_dirrel          = 'top';
my $top_dirabs          = catdir( $project_dirabs, $top_dirrel );
my $top_glob            = $top_dirabs . q{/*};  # ! NOT PLATFORM-INDEPENDENT ?
$command                = join q{ }, (
                            q{cp},              # copy
                            q{-nv},             # no-clobber, verbose
                            $top_glob,          # all files in here
                            $project_dirabs,    # to there
                          );
_shell( $command );



# Cleanup: Remove top-level files except dot.files
opendir $project_dh, $project_dirabs; 
my @loose_files         = readdir $project_dh;
closedir $project_dh;
#~ _talk @loose_files;
foreach (@loose_files) { 
    if ( _unlink_carefully( catfile( $project_dirabs, $_ ) ) ){
        _talk $_ . q{ unlinked.};
    };
};
say q{};

_talk '...Done.';
say q{};
exit(0);

######## INTERNAL ROUTINE ########
#
#   _unlink_carefully( $file_abs );     # delete only files that aren't hidden
#       
# Check to be sure $file_abs is not a folder, symlink, or hidden file.
# If not, delete it. 
#   
sub _unlink_carefully {
    my $file_abs        = $_[0];
    
    return 0 if $file_abs =~ m{\/\.};               # hidden file
                                                    #   also catches ../, ./
    return 0 if not lstat $file_abs;                # lstat failed
                                                    #   symlink not target
    return 0 if -d _;                               # directory
    return 0 if -l _;                               # symlink
    
    unlink $file_abs and return $file_abs;
    return 0;                                       # failed after all
    
}; ## _unlink_carefully

######## INTERNAL ROUTINE ########
#
#   _shell( $command );     # shell out (backticks)
#       
# Shell out the specified command. 
# The command is echoed to the screen first; then its output. 
# Any exit code other than 0 (==bash success) causes a _crash().
#   
sub _shell {
    my $command         = $_[0];
    my $cmdintro        = '> ';
    my $output          ;
    
    # Do it.
    print $cmdintro;
    say $command;
    $output             = `$command`;
    say $output;
    
    # Check exit code.
    if ($? == -1) {
        _crash('shell_failed');
    }
    elsif ($? & 127) {
        _crash('shell_died', ($? & 127) );
    }
    elsif ($?) {
        _crash('shell_error', ($? >> 8) );
    };
    
#~     say q{};
    return 1;
}; ## _shell

######## INTERNAL UTILITY ########
#
#   _talk( @text );         # talk to user
#       
# Prints some message to screen, with introduction. 
# See _crash().
#   
sub _talk {
    my $prepend     = $0;               # prepend to all talk
    my $intro       = q{# };            # introduce each line
       $prepend     = join q{}, $intro, $prepend, q{: };
    my $indent      = qq{\n} . $intro 
                    . q{ } x ( (length $prepend) - (length $intro) )
                    ;
    
    my @lines       = @_;               # all args are printed
    my $text        ;
    
    
    # Expand text and say it
    $text           = $prepend . join $indent, @lines;
    say $text;
    
    return 1;
}; ## _talk

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
            q{Not within a VCS controlled folder.}, 
            q{Suggest cd to top-level project folder and try again.}, 
        ],
        shell_failed    => [
            q{Last shell command failed to execute.},
        ],
        
        shell_died      => [
            qq{Last shell command died with code $_[1].}
        ],
        
        shell_error     => [
            qq{Last shell command exited with code $_[1].}
        ],
        
    };
    
    # find and expand error
    @lines          = @{ $error->{$errkey} };
    $text           = $prepend . join $indent, @lines;
    
    # now croak()
    croak $text;
    return 0;                   # should never get here, though
}; ## _crash

__END__

=pod

pack.pl - Utility script to help Build

* Check to see user cd to VCS controlled project folder
* Save any top-level loose files to .top/
* Copy top/ to ./
* /run/bin/perl Build.PL
* 
* 
* Move tarball to pack/
* Remove top-level files except dot.files
* Restore .top/ to ./

=cut
