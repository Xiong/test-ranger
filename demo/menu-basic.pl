#! /usr/bin/perl -w

use strict;
use Gtk2 '-init';
use Glib qw/TRUE FALSE/; 

#standard window creation, placement, and signal connecting
my $window = Gtk2::Window->new('toplevel');
$window->signal_connect('delete_event' => sub { Gtk2->main_quit; });
$window->set_border_width(5);
$window->set_position('center_always');

#this vbox will return the bulk of the gui
my $vbox = &ret_vbox();

#add and show the vbox
$window->add($vbox);
$window->show();

#our main event-loop
Gtk2->main();

sub ret_vbox {

my $vbox = Gtk2::VBox->new(FALSE,5);
$vbox->set_size_request (300, 300);

    #====================================
    #Start of with a Gtk2::Menu widget
    my $menu_edit = Gtk2::Menu->new();
    
    #--------
    #add a tearoff item
    $menu_edit->append(Gtk2::TearoffMenuItem->new);
    
    #________
    #add an Image Menu item using stock
        my $menu_item_cut = Gtk2::ImageMenuItem->new_from_stock ('gtk-cut', undef);
        #connet to the activate signal to catch when this item is selected
        $menu_item_cut->signal_connect('activate' => sub { print "selected the cut menu\n"});
    $menu_edit->append($menu_item_cut);
    
    #_________
    #add a separator
    $menu_edit->append(Gtk2::SeparatorMenuItem->new());
    
    #_________
    #add a check menu item  
        my $menu_item_toggle = Gtk2::CheckMenuItem->new('_Toggle Menu Item');
        #connect to the toggled signal to catch the active state
        $menu_item_toggle->signal_connect('toggled' => \&toggle,"Toggle Menu Item");
    $menu_edit->append($menu_item_toggle);
    
    #_________
    #add a separator
    $menu_edit->append(Gtk2::SeparatorMenuItem->new());
    
    #_________
    #add radio menu items   
        my $menu_radio_one = Gtk2::RadioMenuItem->new(undef,'Radio one');
        #connect to the toggled signal to catch the changes
        $menu_radio_one->signal_connect('toggled' => \&toggle,"Radio one");
        my $group = $menu_radio_one->get_group;
    $menu_edit->append($menu_radio_one);
    
        my $menu_radio_two = Gtk2::RadioMenuItem->new($group, 'Radio two');
        #connect to the toggled signal to catch the changes
        $menu_radio_two->signal_connect('toggled' => \&toggle,"Radio two");
    $menu_edit->append($menu_radio_two);
    
    #_________
    #add a separator
    $menu_edit->append(Gtk2::SeparatorMenuItem->new());
    
    #_________
    #add an Image Menu Item using an external image
        my $menu_item_image = Gtk2::ImageMenuItem->new ('Image Menu Item');
            my $img = Gtk2::Image->new_from_file('./pix/1.png');
        $menu_item_image->signal_connect('activate' => sub { print "selected the Image Menu Item\n"});
        #connet to the activate signal to catch when this item is selected
        $menu_item_image->set_image($img);
    
    $menu_edit->append($menu_item_image);
    #====================================
    
    #create a menu bar with two menu items, one will have $menu_edit
    #as a submenu       
    my $menu_bar = Gtk2::MenuBar->new;
    
    #_________
    #add a menu item
        my $menu_item_edit= Gtk2::MenuItem->new('_Edit');
        #set its sub menu
        $menu_item_edit->set_submenu ($menu_edit);
                
    $menu_bar->append($menu_item_edit);
    
    #_________
    #add a menu item
        my $menu_item_help = Gtk2::MenuItem->new('_Help');
        $menu_item_help->set_sensitive(FALSE);
        #push it off to the right
        $menu_item_help->set_right_justified(TRUE);
          
    $menu_bar->append($menu_item_help); 

$vbox->pack_start($menu_bar,FALSE,FALSE,0);

    #====================================
    #add an event box to catch the right clicks
    my $eventbox = Gtk2::EventBox->new();

$eventbox->signal_connect('button-release-event' => sub {
    
        my ($widget,$event) = @_;       
        my $button_nr = $event->button;
        #make sure it was the right mouse button                
        ($button_nr == 3)&&($menu_edit->popup(undef,undef,undef,undef,0,0));
        
    });

$vbox->pack_start($eventbox,TRUE,TRUE,0);
$vbox->show_all();
return $vbox;
}

sub toggle {

    my ($menu_item,$text) = @_;
            my $val = $menu_item->get_active;
            ($val)&&(print "$text active\n");
            ($val)||(print "$text not active\n"); 
}
