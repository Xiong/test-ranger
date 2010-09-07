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
my $vcs_dirrel          = '.git';
my $vcs_dirabs          = catdir( $project_dirabs, $vcs_dirrel );
stat $vcs_dirabs or _crash('no_vcs');












# Save any loose top-level files to .save/
my @saved_files         = _get_files($project_dirabs);
my $save_dirrel         = '.save';
my $save_dirabs         = catdir( $project_dirabs, $save_dirrel );
mkdir $save_dirrel or _crash('mkdir_save');
$command                = join q{ }, (
                            q{mv},              # move
                            q{-nv},             # no-clobber, verbose
                            q{-t},              # target first
                            $save_dirabs,       # to there
                            @saved_files,       # all files in here
                          );
_shell( $command );



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


# TODO: Now invoke Module::Build




# Cleanup: Remove top-level files except dot.files

my @cleanup_files       = _get_files($project_dirabs);
my $files_unlinked      = unlink @cleanup_files;
_talk   qq{Unlinked $files_unlinked files:},
        @cleanup_files;
if (not $files_unlinked == scalar @cleanup_files) {
    _grumble('unlink_count', scalar @cleanup_files);
};
say q{};

# Restore saved files to ./
@saved_files            = _get_files($save_dirabs);
@saved_files            = map { catfile $save_dirabs, $_ } @saved_files;
$command                = join q{ }, (
                            q{mv},              # move
                            q{-nv},             # no-clobber, verbose
                            q{-t},              # target first
                            $project_dirabs,    # to there
                            @saved_files,       # all files in here
                          );
_shell( $command );

# rmdir .save
rmdir $save_dirrel or _crash('rmdir_save');






# All finished this script.
_talk '...Done.';
say q{};
exit(0);

#----------------------------------------------------------------------------#

######## INTERNAL ROUTINE ########
#
#   _get_files( $dir_abs );     # list files in folder
#       
# Returns a list of all plain files in $dir_abs. 
# Omits folders, symlinks, hidden files
#   
sub _get_files {
    my $dir_abs         = $_[0];
    my $dh              ;
    my @items           ;
    my @files           ;
    my $previous_dir    = getcwd();
        
    # Get list of items in folder
    opendir $dh, $dir_abs; 
    @items              = readdir $dh;
    closedir $dh;
    
    # chdir so @items, which are just item_names, will work in lstat
    chdir $dir_abs;
    
    # Filter out hidden files, ../ and ./
    @files              = grep {
                                !m/^\./     # hidden, ../, ./
                            &&  lstat       # stats symlink not target
                            &&  -f _        # "plain" file only
                          } @items;
    
    # chdir back so nothing weird happens
    chdir $previous_dir;
    
    return @files;
    
}; ## _get_files

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
#   _grumble( $errkey, @parms );      # complain of internal error
#       
# Calls carp() with some message. 
#   
sub _grumble {
    my $errkey      = $_[0];            # remaining args replace placeholders
    
    # Initialize args; otherwise unused placeholders will raise warnings.
    $_[1] = $_[1] || q{};
    $_[2] = $_[2] || q{};
    $_[3] = $_[3] || q{};
    
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
            qq{Last shell command died with code $_[1].},
            $!
        ],
        
        shell_error     => [
            qq{Last shell command exited with code $_[1].},
            $!
        ],
        
        unlink_count    => [
             q{Failed to unlink expected number of files.},
            qq{Expected number of files to unlink: $_[1].},
             
        ],
        
        mkdir_save      => [
            qq{Failed to mkdir save folder $_[1].},
        ],
        
        rmdir_save      => [
            qq{Failed to rmdir save folder $_[1].},
        ],
        
    };
    
    # find and expand error
    @lines          = @{ $error->{$errkey} };
    push @lines, q{ };
    $text           = $prepend . join $indent, @lines;
    
    # now complain
    carp $text;
    return 1;
}; ## _grumble

######## INTERNAL UTILITY ########
#
#   _crash( $errkey, @parms );      # fatal out of internal error
#   
sub _crash {
    _grumble (@_);
    die;
}; ## _crash

__END__

=pod

pack.pl - Utility script to help Build

I'm tired of wrestling with Module::Build's ways. 

* Check to see user cd to VCS controlled project folder
* cd pack
* cp working tree . (omitting items on some skip list)
* mv files into acceptable M::B tree
* /run/bin/perl Build.PL
* ./Build foo
* cp resulting tarball to hold/tarball/
* extract tarball to unpack/
* rm everything in pack/

=head3 old

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
