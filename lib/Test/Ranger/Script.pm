package Test::Ranger::Script;

use 5.010000;
use strict;
use warnings;
use Carp;
use utf8;

use version 0.94; our $VERSION = qv('v0.0.4');

use Test::Ranger::CS;           # pseudo-global football of state

use Data::Lock qw( dlock );     # Declare locked scalars, arrays, and hashes
use List::MoreUtils qw(
    any all none notall true false firstidx first_index 
    lastidx last_index insert_after insert_after_string 
    apply after after_incl before before_incl indexes 
    firstval first_value lastval last_value each_array
    each_arrayref pairwise natatime mesh zip uniq minmax
);

use Gtk2;                       # Gtk+ GUI toolkit : Do not -init in modules!
use Glib                        # Gtk constants
    'TRUE', 'FALSE',
#    'GDK_CONTROL_MASK',
; ## Glib
use Gnome2::Vte;

## use

# Alternate uses
use Devel::Comments '###';

#============================================================================#

# Constants

# Command line options
#~ dlock( my $option_oneshot     = '-1');    # execute from a script

#----------------------------------------------------------------------------#

# Globals

# Debug and test hashref set in caller
#       -unit       unit testing if true
our $Debug;

#----------------------------------------------------------------------------#

#=========# MAIN INVOCATION ROUTINE
#
#   main();     # invoke Test::Ranger::Script
#       
# Purpose   : Execute top-level routines.
# Parms     : none
# Reads     : @ARGV
# Returns   : $cs       : my pseudo-global football
# Writes    : nothing
# Throws    : nothing
# See also  : _setup(), Test::Ranger::CS::new()
# 
# This is intended to be called from an invocating script. 
# It runs once, calling all needed routines. 
# State is stored in $cs, the "pseudo-global football" passed around. 
# So $cs is a big hash; an object of class Test::Ranger::CS. 
# Most routines in this module expect $cs as a param and return it. 
# 
sub main {    
    my $mw          ;                       # Tk MainWindow object
    my $cs          ;                       # my pseudo-global football
    
    # defaults
    my $mw_width    = 400;
    my $mw_height   = 400;
    
    
    # Create the football
    $cs             = Test::Ranger::CS->new;
    
    # Create the main Window
    $mw             = Gtk2::Window->new ('toplevel');
    $cs->put_mw( $mw );                     # store the Gtk main Window object
    
    # Standard window placement and signal connecting
    $mw->signal_connect( 'delete_event' => sub{_exit()} );
    $mw->set_border_width(5);
    $mw->set_position('center_always');
    $mw->set_default_size ($mw_width, $mw_height);    # initial size
        
    # Initial setup of all GUI elements
    _setup($cs);
    
#~ my @accel_groups    = Gtk2::AccelGroups->from_object ($mw);
#~ ### @accel_groups
    
    # Go!
    $mw->show();
    _main_loop();
    
    return $cs;
}; ## main

#=========# GTK SETUP ROUTINE
#
#   _setup($cs);
#       
# Purpose   : Set up all Gtk stuff. Main method.
# Parms     : $cs
# Reads     : ____
# Returns   : $cs
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
# 
sub _setup {
    my $cs          = shift;
    my $mw          = $cs->get_mw();
    
    # MainWindow title
    $mw->set_title("Test Ranger");
    
    # Outermost box: first item is menubar
    my $vbox0       = Gtk2::VBox->new( FALSE, 5 ); 
                        #( $homo:bool, $spacing:int )
    # $homo = "TRUE means setting $expand TRUE for all packed-in widgets"
    $cs->{-vbox0}   = $vbox0;
    
    # Menu bar
    _setup_menus($cs);      # initial menus on launch
    
    # Keyboard accelerators (hotkeys)
    _setup_hotkeys($cs);    # initial hotkeys on launch
    
    # Panes
    _setup_panes($cs);      # initial window panes
    
    # Terminal
    _setup_terminal($cs);   # virtual terminal emulator
    
    
    
    
#~     # Emergency exit button
#~     my $exit_button ;
#~     $exit_button    = $mw->Button(
#~         -text => "Exit", -command => \&_exit
#~     );
#~     $exit_button->pack;
    
#~     # demo grab keysym -- debug only
#~     $mw->bind('<KeyPress>' => \&print_keysym);
#~     sub print_keysym {
#~         my($widget) = @_;
#~         my $e = $widget->XEvent;    # get event object
#~         my($keysym_text, $keysym_decimal) = ($e->K, $e->N);
#~         print "keysym=$keysym_text, numeric=$keysym_decimal\n";
#~     };

    
    # Display everything
    $vbox0->show_all();
    $mw->add($vbox0);

    return $cs;
}; ## _setup

#=========# GTK SETUP ROUTINE
#
#   _setup_menus($cs);     # initial menus on launch
#       
# Purpose   : ____
# Parms     : ____
# Reads     : ____
# Returns   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
# 
sub _setup_menus {
    my $cs              = shift;
    my $mw              = $cs->get_mw();
    my $vbox0           = $cs->{-vbox0};
    
    # Entire main menubar
    my $menubar         = Gtk2::MenuBar->new;
    $cs->{-menubar}     = $menubar;
    
    # File menu
    my $file_menu       = Gtk2::Menu->new;
    
    # File:Quit
    #   The $dummy_accel does nothing except provoke display of Ctrl-Q.
    #   See _setup_hotkeys() to see what actually makes the hotkey work. 
    my $dummy_accel     = Gtk2::AccelGroup->new;
    my $file_quit       = Gtk2::ImageMenuItem->new_from_stock(
                            'gtk-quit',         # stock item
                            $dummy_accel,       # Gtk2::AccelGroup
                        );
    $file_quit->signal_connect('activate' => sub{_exit()} );
    $file_menu->append($file_quit);
    
    # File:Open...
    # ...
    
    
    
    # The menubar is itself considered a menu, sort of. For each menu: 
    #   Create the "item", which is the menu title
    #   Set the "submenu", which is the menu
    #   Add the menu to the menubar
    
    my $menubar_file    = Gtk2::MenuItem->new('_File');
    $menubar_file->set_submenu ($file_menu);
    $menubar->append($menubar_file);

    ## File menu
    
    # Edit menu
    
    
    
    
    # Help menu
    my $help_menu       = Gtk2::Menu->new;
    
    # Help:About
    my $help_about      = Gtk2::ImageMenuItem->new_from_stock(
                            'gtk-about',        # stock item
                            undef,              # Gtk2::AccelGroup
                        );
    $help_about->signal_connect('activate' => sub{_help_about($cs)} );
    $help_menu->append($help_about);
    
    my $menubar_help    = Gtk2::MenuItem->new('_Help');
    $menubar_help->set_submenu ($help_menu);
    $menubar->append($menubar_help);

    ## Help menu
    
    ## end all the individual menus
    
    # Pack the complete menubar into the display area, at the top
    $vbox0->pack_start( $menubar, FALSE, FALSE, 0 );
                        #( $widget, $expand:bool, $fill:bool, $padding:int )
    
#~     # Emergency exit button
#~     my $exit_button     = Gtk2::Button->new_with_mnemonic('_Quit');
#~     $exit_button->signal_connect( 'clicked' => sub {_exit()} );
#~     $vbox0->pack_start( $exit_button, FALSE, FALSE, 0 );
    
    
    return $cs;
}; ## _setup_menus

#=========# GTK SETUP ROUTINE
#
#   _setup_panes($cs);     # initial window panes
#       
# Purpose   : ____
# Parms     : ____
# Reads     : ____
# Returns   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
# 
sub _setup_panes {
    my $cs          = shift;
    my $mw          = $cs->get_mw();
    
    # Outermost box includes menubar and everything else
    my $vbox0           = $cs->{-vbox0};
    
    # Top-and-bottom panes inside outermost vbox0
    my $panebox1        = Gtk2::VPaned->new;
    $vbox0->pack_start( $panebox1, TRUE, TRUE, 0 );
                        #( $widget, $expand:bool, $fill:bool, $padding:int )
    
    # Side-by-side panes inside top of panebox1
    my $panebox2        = Gtk2::HPaned->new;
    $panebox1->pack1( $panebox2, TRUE, TRUE );
                        #( $widget, $resize:bool, $shrink:bool )

    # Top-and-bottom panes inside bottom of panebox1
    my $panebox3        = Gtk2::VPaned->new;
    $panebox1->pack2( $panebox3, TRUE, TRUE );
                        #( $widget, $resize:bool, $shrink:bool )

    # Create a VBox for each pane
    my $A_pane      = Gtk2::VBox->new( FALSE, 5 ); 
    my $B_pane      = Gtk2::VBox->new( FALSE, 5 ); 
    my $C_pane      = Gtk2::VBox->new( FALSE, 5 ); 
    my $D_pane      = Gtk2::VBox->new( FALSE, 5 ); 
                        #( $homo:bool, $spacing:int )
    # $homo = "TRUE means setting $expand TRUE for all packed-in widgets"
    
    # Pack the panes into where they go.
    $panebox2->pack1( $A_pane, TRUE, TRUE );
    $panebox2->pack2( $B_pane, TRUE, TRUE );
    $panebox3->pack1( $C_pane, TRUE, TRUE );
    $panebox3->pack2( $D_pane, TRUE, TRUE );
    
    # Dummy labels for checkout         - disable soon
    my $label_A_pane        = 'A';
    my $label_B_pane        = 'B';
    my $label_C_pane        = 'C';
    my $label_D_pane        = 'D';
    
    my $A_dummy           = Gtk2::Label->new;
    $A_dummy->set_markup($label_A_pane);
    my $B_dummy           = Gtk2::Label->new;
    $B_dummy->set_markup($label_B_pane);
    my $C_dummy           = Gtk2::Label->new;
    $C_dummy->set_markup($label_C_pane);
    my $D_dummy           = Gtk2::Label->new;
    $D_dummy->set_markup($label_D_pane);
    
    $A_pane->pack_start( $A_dummy, FALSE, FALSE, 0 );
    $B_pane->pack_start( $B_dummy, FALSE, FALSE, 0 );
    $C_pane->pack_start( $C_dummy, FALSE, FALSE, 0 );
    $D_pane->pack_start( $D_dummy, FALSE, FALSE, 0 );
                        #( $widget, $expand:bool, $fill:bool, $padding:int )
    
    # Store the panes and Vboxes for later access
    $cs->{'-A_pane'}    = $A_pane;
    $cs->{'-B_pane'}    = $B_pane;
    $cs->{'-C_pane'}    = $C_pane;
    $cs->{'-D_pane'}    = $D_pane;
    
    
    
        
    return $cs;
}; ## _setup_panes

#=========# GTK SETUP ROUTINE
#
#   _setup_hotkeys($cs);     # short
#       
# Purpose   : ____
# Parms     : ____
# Reads     : ____
# Returns   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
# 
sub _setup_hotkeys {
    my $cs          = shift;
    my $mw          = $cs->get_mw();
    
    my $control_key     = 'control-mask';       # Ctr-...
    my $keycode_q       = 113;                  # ...Q
    my $flag_visible    = 'visible';
    
    my $quit_accel      = Gtk2::AccelGroup->new;
    $quit_accel->connect(
                            $keycode_q,         # $key:int (see demo/kbd.pl)
                            $control_key,       # modifier
                            $flag_visible,      # flags
                            sub{_exit()},       # callback
                        );
    $mw->add_accel_group($quit_accel);
        
    return $cs;
}; ## _setup_hotkeys

#=========# GTK CALLBACK
#
#   _help_about($cs);     # short
#       
# Purpose   : Display application information
# Parms     : ____
# Reads     : ____
# Returns   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
# 
sub _help_about {
    my $cs          = shift;
    my $mw          = $cs->get_mw();
    
    my $text        = join q{},
        qq*<span foreground = "blue" size = "x-large" weight = "bold">*,
        qq*Test Ranger*, qq{\n},
        qq* </span>*, qq{\n},
        qq*<span weight = "bold">Version $VERSION</span>*, qq{\n},
        qq* *, qq{\n},
        qq*Copyright © 2011 Xiong Changnian*,
#~          q{\<xiong\@cpan.org\>*}, 
        qq{\n},
        qq*This application is released under Artistic License 2.0:*, qq{\n},
        qq*http://www.opensource.org/licenses/artistic-license-2.0.php*, qq{\n},
        qq* *, qq{\n},
        qq*Download this package from CPAN as Test::Ranger.*, qq{\n},
        qq*For help, choose from Help menu or type: *,
        qq*<span weight = "bold">perldoc test-ranger</span>*, qq{\n},
        qq* *, qq{\n},
        qq*This application is written using Perl 5 and Gtk+.*,
#~         qq*             *,
#~         qq*             *,
#~         qq*             *,
#~         qq*             *,
    ; ##
    
#~     say 'about';
        
    _modal_dialog(
        $mw,
        'info',
        $text,
        'ok',
    );
    
    return FALSE;       # propagate this signal
}; ## _help_about

#=========# INTERNAL ROUTINE
#
#   _modal_dialog();     # short
#       
# Purpose   : Displays a modal dialog and exits on user click of button.
# Parms     : 
#       $parent       : parent window or undef
#       $icon         : 'info', 'warning', 'error', 'question'
#       $text         : plain text or pango markup
#       $button_type  : 'none', 'ok', 'close', 'cancel', 'yes-no', 'ok-cancel'
# Reads     : $cs
# Returns   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
# 
sub _modal_dialog {
#~     my $cs          = shift;
#~     my $mw          = $cs->get_mw();
    
    my ( $parent, $icon, $text, $button_type ) = @_;
 
    my $dialog = Gtk2::MessageDialog->new_with_markup (
                    $parent,
                    [qw/modal destroy-with-parent/],
                    $icon,
                    $button_type,
                    sprintf "$text"
                ); ##
        
    my $return_value = $dialog->run;
    
    #destroy the dialog as it comes out of the 'run' loop   
    $dialog->destroy;
    
    return $return_value;
}; ## _modal_dialog

#=========# GTK SETUP ROUTINE
#
#   _setup_terminal($cs);     # short
#       
# Purpose   : Create a virtual terminal emulator widget.
# Parms     : ____
# Reads     : ____
# Returns   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
# 
sub _setup_terminal {
    my $cs          = shift;
    my $mw          = $cs->get_mw();
    my $term_pane   = $cs->{'-D_pane'};
    
    # create things
    my $scrollbar = Gtk2::VScrollbar->new;
    my $hbox = Gtk2::HBox->new;
    my $terminal = Gnome2::Vte::Terminal->new;
    
    # set up scrolling
    $scrollbar->set_adjustment ($terminal->get_adjustment);
    
    # lay 'em out
    $term_pane->add ($hbox);
    $hbox->pack_start ($terminal, TRUE, TRUE, 0);
    $hbox->pack_start ($scrollbar, FALSE, FALSE, 0);
#~     $window->show_all;
    
    # hook 'em up
    $terminal->fork_command ('/bin/bash', ['bash', '-login'], undef,
                           '/tmp', FALSE, FALSE, FALSE);
#~     $terminal->signal_connect (child_exited => sub { Gtk2->main_quit });
#~     $window->signal_connect (delete_event =>
#~                            sub { Gtk2->main_quit; FALSE });
    
    
    
    return $cs;
}; ## _setup_terminal

#=========# GTK SETUP ROUTINE
#
#   _do_();     # short
#       
# Purpose   : ____
# Parms     : ____
# Reads     : ____
# Returns   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
# 
sub _do_ {
    my $cs          = shift;
    my $mw          = $cs->get_mw();
    
    
    return $cs;
}; ## _do_

#=========# GTK CALLBACK
#
#   _exit();     # short
#       
# Purpose   : Quit, leave, exit, go bye-bye.
# Parms     : ____
# Reads     : ____
# Returns   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
# 
sub _exit {
    
    Gtk2->main_quit;
    
    return TRUE;        # do not propagate this signal
}; ## _exit

#=========# INTERNAL ROUTINE
#
#   _main_loop();     # short
#       
# Purpose   : ____
# Parms     : ____
# Reads     : ____
# Returns   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
# 
sub _main_loop {
    
        Gtk2->main;                             # run main event loop
    
}; ## _main_loop




## END MODULE
1;
#============================================================================#
__END__

=head1 NAME

Test::Ranger::Script - GUI valet for comprehensive test structure

=head1 VERSION

This document describes Test::Ranger::Script version v0.0.4

=head1 SYNOPSIS

    # Invoke:
    
    $ test-ranger

=head1 DESCRIPTION

=over

I<The computer should be doing the hard work.> 
I<That's what it's paid to do, after all.>
-- Larry Wall

=back

TODO

=head1 INTERFACE 

TODO

=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

TODO

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.

Test::Ranger requires no configuration files or environment variables.

=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.

=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.

=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.


Please report any bugs or feature requests to
C<bug-test-ranger@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Xiong Changnian  C<< <xiong@cpan.org> >>

=head1 LICENSE

Copyright (C) 2011 Xiong Changnian C<< <xiong@cpan.org> >>

This library and its contents are released under Artistic License 2.0:

L<http://www.opensource.org/licenses/artistic-license-2.0.php>

=cut
