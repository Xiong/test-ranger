#!/run/bin/perl
#       frames.pl
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

use Gtk2 '-init';
use Glib qw/TRUE FALSE/; 

    #standard window creation, placement, and signal connecting
    my $mw = Gtk2::Window->new('toplevel');
    $mw->signal_connect('delete_event' => sub { Gtk2->main_quit; });
    $mw->set_border_width(5);
    $mw->set_position('center_always');
    
    
    
    
    
    
    # Show and run.
    $mw->show_all();
    Gtk2->main();



__DATA__

Output: 


__END__
