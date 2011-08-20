#!/run/bin/perl

use strict;
use Glib qw(TRUE FALSE);
use Gtk2 -init;
use Gnome2::Vte;

# create things
my $window = Gtk2::Window->new;
my $scrollbar = Gtk2::VScrollbar->new;
my $hbox = Gtk2::HBox->new;
my $terminal = Gnome2::Vte::Terminal->new;

# set up scrolling
$scrollbar->set_adjustment ($terminal->get_adjustment);

# lay 'em out
$window->add ($hbox);
$hbox->pack_start ($terminal, TRUE, TRUE, 0);
$hbox->pack_start ($scrollbar, FALSE, FALSE, 0);
$window->show_all;

# hook 'em up
$terminal->fork_command ('/bin/bash', ['bash', '-login'], undef,
                       '/tmp', FALSE, FALSE, FALSE);
$terminal->signal_connect (child_exited => sub { Gtk2->main_quit });
$window->signal_connect (delete_event =>
                       sub { Gtk2->main_quit; FALSE });

# turn 'em loose
Gtk2->main;

__END__
