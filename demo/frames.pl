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
    _setup_hotkeys();
    
    # Add a definite thing. 
    my $vbox0           = Gtk2::VBox->new();
    $mw->add($vbox0);

    my $button1          = Gtk2::Button->new('Dummy1');
    $vbox0->pack_start($button1, FALSE, FALSE, 0);
    
    my $button2          = Gtk2::Button->new('Dummy2');
    $vbox0->pack_start($button2, FALSE, FALSE, 0);
    
    
    # Show and run.
    $mw->show_all();
    Gtk2->main();

sub _setup_hotkeys {
#~     my $cs          = shift;
#~     my $mw          = $cs->get_mw();
    
    my $control_key     = 'control-mask';       # Ctr-...
    my $keycode_q       = 113;                  # ...Q
    my $flag_visible    = 'visible';
    
    my $quit_accel      = Gtk2::AccelGroup->new;
    $quit_accel->connect(
                            $keycode_q,         # $key:int (see demo/kbd.pl)
                            $control_key,       # modifier
                            $flag_visible,      # flags
                            sub{ Gtk2->main_quit; },       # callback
                        );
    $mw->add_accel_group($quit_accel);
#~     $window->add_accel_group($quit_accel);
        
#~     return $cs;
}; ## _setup_hotkeys


__DATA__

Output: 


__END__
