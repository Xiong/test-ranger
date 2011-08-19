#!/run/bin/perl
use warnings;
use strict;
use Gtk2;

init Gtk2;

my $window = new Gtk2::Window 'toplevel';
$window ->signal_connect( 'destroy' => sub{ Gtk2->main_quit;
                                           return 0;
                                          } );

my $frame = new Gtk2::Frame "embedded rxvt-unicode terminal";

$window->add ($frame);

my $rxvt = new Gtk2::Socket;

$frame->add ($rxvt);
$frame->set_size_request (700, 400);
$window->show_all;
my $xid = $rxvt->window->get_xid;

# works with rxvt but xterm loses keyboard focus
#system "xterm -into $xid &";
#~ system "urxvt -embed $xid -e mc &";
#~ system "rxvt -embed $xid -e mc &";
system "mrxvt -embed $xid -e mc &";

$window->show_all;

$rxvt->add_events([ qw( all_events_mask key_press_mask ) ]);

#needs 0 not 1 for second arg
#my $rc = Gtk2::Gdk->keyboard_grab($rxvt->window, 0 ,Gtk2->get_current_event_time);
#warn "keyboard grab failed ($rc)\n" unless $rc eq 'success';
#print "$rc\n";

main Gtk2;
