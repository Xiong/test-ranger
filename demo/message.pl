#! /run/bin/perl -w

use strict;
use Glib qw/TRUE FALSE/;
use Gtk2 '-init'; 

#create a label that may be changed from various places
my $label_feedback;

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

#create a flasher for the label, we will show or hide it every 1 second
my $flash = 1;
Glib::Timeout->add (1000,sub{ &flash_label() });

#our main event-loop
Gtk2->main();


sub ret_vbox {

#create a vbox to pack the following widgets
my $vbox = Gtk2::VBox->new(FALSE,5);

    
    $label_feedback = Gtk2::Label->new();
    $label_feedback->set_markup("<span foreground=\"blue\" size=\"x-large\">Response from Gtk2::Dialog's 'run' method:\n</span><span weight='heavy' size = '20000' foreground = 'forestgreen' style ='italic'> \n</span>");
    
#Label at the bottom of the VBox    
$vbox->pack_end($label_feedback,FALSE,FALSE,4);
#On top of that, a HSeparator
$vbox->pack_end(Gtk2::HSeparator->new(),FALSE,FALSE,4);

    my $btn_start = Gtk2::Button->new("Show MESSAGE types - Parent = 'undef'");
    #we start an anonymous sub when the button is clicked
    $btn_start->signal_connect('clicked' => sub { 
        #we ask Glib to give a list of values for Gtk2::MessageType.
        #Each value of the list is a hash with keys "name" and "nick",
        #we then use the value of "nick" to specify the type to show.
        foreach my $m_type (Glib::Type->list_values ('Gtk2::MessageType')){
            &show_message_dialog(undef,$m_type->{'nick'},"Message type:\n$m_type->{'nick'}\nNow Showing!\n\n<sub><u>Invoked it by:\n</u><span foreground='SteelBlue'>Gtk2::MessageDialog->new (undef,
                    [qw/modal destroy-with-parent/],
                    <span foreground='forestgreen'>$m_type->{'nick'},</span>
                    'ok',
                    \"(Text goes here)\");</span></sub>",'ok');
                    
        }
    });
$vbox->pack_start($btn_start,FALSE,FALSE,4);

    my $btn_markup = Gtk2::Button->new("Show MESSAGE types\n-With Pango Markup-");
    #we start an anonymous sub when the button is clicked
    $btn_markup->signal_connect('clicked' => sub { 
        #we ask Glib to give a list of values for Gtk2::MessageType.
        #Each value of the list is a hash with keys "name" and "nick",
        #we then use the value of "nick" to specify the type to show.
        foreach my $m_type (Glib::Type->list_values ('Gtk2::MessageType')){
            &show_message_dialog($window,$m_type->{'nick'},"<span foreground=\"blue\" size=\"x-large\">Message Type\n</span><span weight='heavy' size = '20000' foreground = 'red' style ='italic'>$m_type->{'nick'}\n</span><sub><tt>Now Showing!\n\n</tt></sub><sub><u>Invoked it by:\n</u><span foreground='SteelBlue'>Gtk2::MessageDialog->new_with_markup (\$window,
                    [qw/modal destroy-with-parent/],
                    <span foreground='forestgreen' >$m_type->{'nick'},</span>
                    'ok',
                    \"(markup goes here)\");</span></sub>",'ok');
        
        }
    });
    
$vbox->pack_start($btn_markup,FALSE,FALSE,4);

my $btn_button_types = Gtk2::Button->new("Show BUTTON types");

    #we start an anonymous sub when the button is clicked
    $btn_button_types->signal_connect('clicked' => sub { 
        #we ask Glib to give a list of values for Gtk2::ButtonsType.
        #Each value of the list is a hash with keys "name" and "nick",
        #we then use the value of "nick" to specify the button to show.
        foreach my $b_type (Glib::Type->list_values ('Gtk2::ButtonsType')){
            my $b_type_nick = $b_type->{'nick'};
            &show_message_dialog($window,'info',"<span foreground=\"blue\" size=\"x-large\">Button Type\n</span><span weight='heavy' size = '20000' foreground = 'red' style ='italic'>$b_type_nick\n</span><sub><tt><u>Now Showing!\n\n</u></tt></sub><sub><u>Invoked it by:\n</u><span foreground='SteelBlue'>Gtk2::MessageDialog->new_with_markup (\$window,
                    [qw/modal destroy-with-parent/],
                    'info',
                    <span foreground='forestgreen' >\"$b_type_nick\",</span>
                    \"(markup goes here)\");</span></sub>",$b_type_nick);
        
        }
    });
    
$vbox->pack_start($btn_button_types,FALSE,FALSE,4);

$vbox->show_all();

return $vbox;

}

sub show_message_dialog {

#THIS IS THE MAIN FEATURE OF THE APP:
#you tell it what to display, and how to display it
#$parent is the parent window, or "undef"
#$icon can be one of the following: a) 'info'
#                   b) 'warning'
#                   c) 'error'
#                   d) 'question'
#$text can be pango markup text, or just plain text, IE the message
#$button_type can be one of the following:  a) 'none'
#                       b) 'ok'
#                       c) 'close'
#                       d) 'cancel'
#                       e) 'yes-no'
#                       f) 'ok-cancel'

my ($parent,$icon,$text,$button_type) = @_;
 
my $dialog = Gtk2::MessageDialog->new_with_markup ($parent,
                    [qw/modal destroy-with-parent/],
                    $icon,
                    $button_type,
                    sprintf "$text");
        
    #this will typically return certain values depending on the value of $retval.
    #in this application, we only change the label's value accordingly                              
    my $retval = $dialog->run;
    $label_feedback->set_markup("<span foreground=\"blue\" size=\"x-large\">Response from Gtk2::Dialog's 'run' method:\n</span><span weight='heavy' size = '20000' foreground = 'forestgreen' style ='italic'>$retval\n</span>");
    #destroy the dialog as it comes out of the 'run' loop   
    $dialog->destroy;
}

sub flash_label {
#label flasher
($flash)&&($label_feedback->hide());
($flash)||($label_feedback->show());
$flash = !($flash);
return TRUE;

}
