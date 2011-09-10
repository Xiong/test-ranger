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
use Devel::Comments '###', ({ -file => 'parse.log' });

#
my $session_file    = $ARGV[0];
say "Session: $session_file";
open my $fh, '<', $session_file
    or die "Couldn't open $session_file for reading ", $!;
while (<$fh>) {
    my $line        = $_;
   _parse_script( undef, $line );     # parse lines of 'script(1)'
    
};

close $fh;


#=========# INTERNAL CHILD ROUTINE
#
#   _parse_script( $cs, $text );     # parse lines of 'script(1)'
#       
# Purpose   : Clean up escapes and dispatch script output for further action.
# Parms     : $cs           : football
#             $text         : captured string
# Reads     : ____
# Returns   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# The shell command 'script(1)' captures *everything* from the terminal.
# We must strip out the useless stuff, process the codes, and see what's what.
#
# The procedure is modeled on:
# http://www.ncssm.edu/~cs/index.php?loc=logging.html&callPrintLinuxSupport=1
# 
sub _parse_script {
    my $cs          = shift;
    my $text        = shift;
#~ ### Start: $text
    
    # Drop trailing newlines            # debug only
    $text          =~ s/[(\n)(\x0d)(\x0a)]+$//g;
### Pass1: $text
    
    # Apply monster regex. No, I don't quite know what it does. 
    $text          =~ s/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g;
### Pass2: $text
    
    # Deal with backspaces.
    my $bs          = qr/\x08/;
    $text          =~ s/[^($bs)](?R)?($bs)//g;
#~     $text          =~ s/[^(\b)](?R)?[\b]//g;
### Pass3: $text
    
#~     # Further process through 'col(1)'. 
#~     $text           = `col -b $text`;   # -b: Do not print backspaces.
#~     die "Bad col $?"
#~         if $?;
    
    return 1;
}; ## _parse_script


__DATA__

Output: 


__END__
