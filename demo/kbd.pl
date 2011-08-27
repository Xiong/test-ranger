#! /usr/bin/perl -w
use strict;
use Gtk2::Gdk::Keysyms;
use Glib qw/TRUE FALSE/;
use Gtk2 -init;

my $window = Gtk2::Window->new ('toplevel');
$window->signal_connect (delete_event => sub { Gtk2->main_quit });
$window->signal_connect('key-press-event' => \&show_key);
    
    my $label = Gtk2::Label->new();
    $label->set_markup("<span foreground=\"blue\" size=\"x-large\">Type something on the keyboard!</span>");
    
$window->add ($label);
$window->show_all;
$window->set_position ('center-always');

Gtk2->main;

sub show_key {

my ($widget,$event,$parameter)= @_;

my $key_nr = $event->keyval();

    #run trough the available key names, and get the values of each,
    #compare this with $event->keyval(), when you get a match exit the loop
    foreach my $key  (keys %Gtk2::Gdk::Keysyms){
    
        my $key_compare = $Gtk2::Gdk::Keysyms{$key};
        
        if($key_compare == $key_nr){
        #print ("You typed $key \n");
        $label->set_markup("<span foreground=\"blue\" size=\"x-large\">You typed a</span><span foreground=\"red\" size=\"30000\"><i><tt> $key</tt></i></span><span foreground=\"blue\" size=\"x-large\"> which has a numeric value of </span><span foreground=\"red\" size=\"30000\"><i><tt> $key_nr!</tt></i></span>");
        $widget->set_title("key pressed: $key -> numeric value: $key_nr");
        last;
        }
    }
    #good practice to let the event propagate, should we need it somewhere else
    return FALSE;
}
