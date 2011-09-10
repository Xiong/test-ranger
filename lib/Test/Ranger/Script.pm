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

use POSIX qw( mkfifo :sys_wait_h );

use Gtk2;                       # Gtk+ GUI toolkit : Do not -init in modules!
use Glib                        # Gtk constants
    'TRUE', 'FALSE',
; ## Glib
use Gnome2::Vte;

## use

# Alternate uses
#~ use Devel::Comments '###';
use Devel::Comments '#####', ({ -file => 'tr-debug.log' });

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
    my $cs          ;                       # my pseudo-global football
    my $mw          ;                       # Gtk main Window object
    
    # Create the football
    $cs             = Test::Ranger::CS->new;
    
    # Load cascading configurations from config files.
    $cs->get_config();
    
    # main Window configuration
    my $mw_width    = $cs->{-config}{-mw_initial_H};
    my $mw_height   = $cs->{-config}{-mw_initial_V};
    my $mw_anchor   = $cs->{-config}{-mw_anchor};
    
    # Create the main Window
    $mw             = Gtk2::Window->new ('toplevel');
    $cs->put_mw( $mw );                     # store the Gtk main Window object
    
    # Standard window placement and signal connecting
    $mw->signal_connect( 'delete_event' => sub{quit($cs)} );
    $mw->set_border_width(0);
    $mw->set_position( $mw_anchor );
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
    
    
    # Futz around here.

#    # Set colors
#    my $max       = 65535;
##~     my $bg_color    = $cs->get_color_of('-terminal_bg_color');
#    my $bg_color    = $cs->get_color_of( [$max, $max, $max, 0] );
##~     my $bg_color    = $cs->get_color_of( [0, 0, 0, 0] );
#### $bg_color
    
##~     $terminal->set_background_tint_color($bg_color);
##~     $terminal->set_background_saturation($max);
    
    
#    # Emergency exit button
#    my $exit_button     = Gtk2::Button->new_with_mnemonic('_Quit');
#    $exit_button->signal_connect( 'clicked' => sub {quit($cs)} );
#    $vbox0->pack_start( $exit_button, FALSE, FALSE, 0 );
    
#    $exit_button->modify_bg('normal', $bg_color);
    
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
    $file_quit->signal_connect('activate' => sub{quit($cs)} );
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
#~     $exit_button->signal_connect( 'clicked' => sub {quit($cs)} );
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
    my $cs              = shift;
    my $mw              = $cs->get_mw();
    
    my @frames          ;
    my $frame_type      = $cs->{-config}{-frame_type};
    my @frame_labels    ;
    my $ref             = $cs->{-config}{-frame_labels};
#~     my $ref             = '';
    if ($ref) {                             # $ref might be undef
        if ( ref $ref && join q{}, @$ref) {     # @ref might be false or empty
            @frame_labels = @$ref;
        };
    };
    my @panes           ;
    my $pane_homo       = $cs->{-config}{-pane_homo};
    my $pane_spacing    = $cs->{-config}{-pane_spacing};
    
    # Outermost box includes menubar and everything else
    my $vbox0           = $cs->{-vbox0};
    
    # Top-and-bottom frames inside outermost vbox0
    my $panebox1        = Gtk2::VPaned->new;
    $vbox0->pack_start( $panebox1, TRUE, TRUE, 0 );
                        #( $widget, $expand:bool, $fill:bool, $padding:int )
    
    # Side-by-side frames inside top of panebox1
    my $panebox2        = Gtk2::HPaned->new;
    $panebox1->pack1( $panebox2, TRUE, TRUE );
                        #( $widget, $resize:bool, $shrink:bool )

    # Top-and-bottom frames inside bottom of panebox1
    my $panebox3        = Gtk2::VPaned->new;
    $panebox1->pack2( $panebox3, TRUE, TRUE );
                        #( $widget, $resize:bool, $shrink:bool )

    # Create a Frame for each pane
    my $A_frame     = Gtk2::Frame->new(); 
    my $B_frame     = Gtk2::Frame->new(); 
    my $C_frame     = Gtk2::Frame->new(); 
    my $D_frame     = Gtk2::Frame->new();
    push @frames, $A_frame, $B_frame, $C_frame, $D_frame; 
    
    # Style each frame
    for (@frames) {
        my $frame   = $_;
        $frame->set_shadow_type($frame_type);
        if (@frame_labels) {
            $frame->set_label( shift @frame_labels);
        };
    };
    
    # Pack the frames into where they go.
    $panebox2->pack1( $A_frame, TRUE, TRUE );
    $panebox2->pack2( $B_frame, TRUE, TRUE );
    $panebox3->pack1( $C_frame, TRUE, TRUE );
    $panebox3->pack2( $D_frame, TRUE, TRUE );
    
    # Put inside VBox "panes" inside the outside Frame "frames". 
    for (@frames) {
        my $frame   = $_;
        my $pane    = Gtk2::VBox->new( $pane_homo, $pane_spacing );
                            #( $homo:bool, $spacing:int )
    # $homo = "TRUE means setting $expand TRUE for all packed-in widgets"
        $frame->add($pane);
        push @panes, $pane;
    };
        
    # Dummy labels for checkout         - disable soon
    my $label_A        = 'A';
    my $label_B        = 'B';
    my $label_C        = 'C';
    my $label_D        = 'D';
    
    my $A_dummy           = Gtk2::Label->new;
    $A_dummy->set_markup($label_A);
    my $B_dummy           = Gtk2::Label->new;
    $B_dummy->set_markup($label_B);
    my $C_dummy           = Gtk2::Label->new;
    $C_dummy->set_markup($label_C);
    my $D_dummy           = Gtk2::Label->new;
    $D_dummy->set_markup($label_D);
    
#~     $A_pane->pack_start( $A_dummy, FALSE, FALSE, 0 );
#~     $B_pane->pack_start( $B_dummy, FALSE, FALSE, 0 );
#~     $C_pane->pack_start( $C_dummy, FALSE, FALSE, 0 );
#~     $D_pane->pack_start( $D_dummy, FALSE, FALSE, 0 );
#~                         #( $widget, $expand:bool, $fill:bool, $padding:int )
    
    # Set specific frame defaults.
    # These will control where new tabs are put.
    my $term_frame      = $cs->{-config}{-terminal_frame};
    $term_frame        =~ tr/ABCD/0123/;
    $cs->{-term_frame}  = $term_frame;
    
    # Store the Frames and VBox panes for later access
    $cs->{-frames}      = \@frames;
    $cs->{-panes}       = \@panes;
    
        
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
                            sub{quit($cs)},     # callback
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
    my $term_frame  = $cs->{-term_frame};
    my $term_pane   = $cs->get_pane($term_frame);
    my $vbox        = Gtk2::VBox->new;
    
    # create things
    my $scrollbar   = Gtk2::VScrollbar->new;
    my $hbox        = Gtk2::HBox->new;
    my $terminal    = Gnome2::Vte::Terminal->new;
#~     $cs->{-terminal}    = $terminal;
    
    # set up scrolling
    $scrollbar->set_adjustment ($terminal->get_adjustment);
    
    # lay 'em out
    $term_pane->add($vbox);
    $vbox->pack_start($hbox,        FALSE,  FALSE,  0);
    $hbox->pack_start($terminal,    TRUE,   TRUE,   0);
    $hbox->pack_start($scrollbar,   FALSE,  FALSE,  0);
    
    # Set colors
#~     my $bg_color    = $cs->get_color_of( 'straw' );
#~     my $fg_color    = $cs->get_color_of( 'black' );
    my $bg_color    = $cs->get_color_of( '-terminal_color_background' );
    my $fg_color    = $cs->get_color_of( '-terminal_color_foreground' );
    
#    # A 16-element array(ref) of Gtk2::Gdk::Color objects.
#    my $palette_ref     = [];
#    for (0..15) { push @$palette_ref, $cs->get_color_of( [0, 0, 0, 0] ) };
#    $terminal->set_colors( $fg_color, $bg_color, $palette_ref );

    $terminal->set_colors( $fg_color, $bg_color, [] ); # okay
    
#~     $terminal -> set_default_colors();      # reset to white-on-black
    
    # hook 'em up
    my $command     = '/bin/bash';          # shell to start
#~     my $command     = '/usr/bin/script -a STDOUT ';          # shell to start
#~     my $command     = '/home/xiong/projects/test-ranger/bin/script-helper.sh ';          # shell to start
#~     say `ls $command`;
    my $arg_ref     = ['bash', '-login'];   # ARGV?
#~     my $arg_ref     = ['script', '-login'];   # ARGV?
#~     my $arg_ref     = ['script-helper.sh', '-login'];   # ARGV?
    my $env_ref     = undef;                # ENV?
    my $directory   = '',                   # 'foo' is relative to parent
    my $lastlog     = FALSE;                # ?
    my $utmp        = FALSE;                # ?
    my $wtmp        = FALSE;                # ?
    $terminal->fork_command (
        $command,
        $arg_ref,
        $env_ref,
        $directory,
        $lastlog,
        $utmp,
        $wtmp,
    );
    
#~     $terminal->signal_connect (child_exited => sub { Gtk2->main_quit });
    
    
    # Start logging on first display of bash prompt.
    my $id  = $terminal->signal_connect( 'text-inserted' => 
        \&make_logger, $cs 
    ); ## terminal signal
#### $id
    # Store $id to disconnect this signal after first reception. 
    $cs->{-terminal_connect_id}{$terminal} = $id;
    
    
    # Test feed button
    my $feed_button     = Gtk2::Button->new_with_mnemonic('_Feed');
    $feed_button->signal_connect( 'clicked' => \&test_feed, $terminal );
    $vbox->pack_start( $feed_button, FALSE, FALSE, 0 );
    
#~     # Test echo box
#~     my $echo_buf        = Gtk2::TextBuffer->new();
#~     my $echo_view       = Gtk2::TextView->new_with_buffer($echo_buf);
#~     my $buffer_ball     = {
#~                             -echo_buf       => $echo_buf,
#~                             -previous_row   => 0,
#~                             -previous_col   => 0,
#~                             -row_count      => 0,
#~                         };
#~     
#~     $terminal->signal_connect( 'text-inserted' => 
#~         \&test_echo, $buffer_ball 
#~     ); ## terminal signal
#~     
#~     $vbox->pack_start( $echo_view, FALSE, FALSE, 0 );
    
    
    
    return $cs;
}; ## _setup_terminal

# scratch test feed sub
sub test_feed {
    my $self        = shift;
    my $terminal    = shift;
    my $feed        = 'ls';
    
    $terminal->feed_child($feed);
    $terminal->grab_focus();
    
    return FALSE;       # propagate this signal
};

#=========# GTK CALLBACK
#
#   make_logger($cs);     # short
#       
# Purpose   : Use a fifo and 'script(1)' to carry away 
#             terminal session traffic to an internal routine. 
#             (This now, for debug purposes, STDOUT.)
# Parms     : $terminal : terminal instance to log
#             $cs       : football
#             $id       : id of *this* handler
# Reads     : $cs->{-terminal_connect_id}{$terminal}
# Signal    : 'text-inserted'
# Returns   : propagate
# Writes    : ____
# Throws    : ____
# See also  : _setup_terminal()
# 
# The logger is started in the terminal /post facto/, after bash starts.
# So wait until the first signal, disconnect the signal, and start logger. 
# 
# 'script' grabs all traffic and writes it to a "file", 
#   which is a fifo ("named pipe") created by POSIX::mkfifo(). 
# Either of reader or writer will block until 
#   the other is also connected to the same fifo. 
# So, create the listener as a child first; then invoke 'script'. 
# 
sub make_logger {
    my $terminal    = shift;
    my $cs          = shift;
    my $id          = $cs->{-terminal_connect_id}{$terminal};
#### Begin make_logger
#### $terminal
#### $cs
#### $id
    
    # Disconnect the signal immediately after first reception.
    $terminal->signal_handler_disconnect( $id );
    
    # Create, then listen-in on fifo... 
    
    # Create fifo.
    my $fifo        = "tr_fifo_$id";        # arbitrary but unique (?)
    mkfifo( $fifo, 0700 ) 
        or die "mkfifo $fifo failed: $!";
    push @{ $cs->{-fifos} }, $fifo;
    
    # Fork, to avoid hang up waiting for the other half of the fifo.
    my $pid     = fork;
    if (not defined $pid) { die 'Failed to fork.' };
    # Am I parent or child?
    if   ( $pid ) {         # parent
        push @{ $cs->{-child_pid} }, $pid;
    } 
    else {                  # child
        # Open fifo. 
        open my $fh, '<', $fifo
            or die "Failed to open $fifo for reading ", $!;
    
        while (<$fh>) {
            _parse_script( $cs, $_ );       # parse lines of 'script(1)'
        };
        close $fh
            or die "Failed to close $fifo for reading ", $!;
        exit(0);
    };
    
    # Start logging
    my $command 
        = qq{script -f -a $fifo};
    $terminal->feed_child( $command . qq{\n} );
    
    # Register this subshell in football for later 'exit'-ing.
    push @{ $cs->{-term_with_subshell} }, $terminal;
    
    return FALSE;       # propagate this signal
}; ## make_logger

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
    my $matches     ;
    my $prompt      ;
    my $bel         = '\x07';       # ASCII BEL ("bell")
    
    # Drop trailing newlines            # debug only
    $text          =~ s/[(\n)(\x0d)(\x0a)]+$//g;
    
my $t0 = $text;
    # Apply monster regex. No, I don't quite know what it does. 
    #                       Gets rid of escape sequences. 
    $text      =~ s/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g;
    
my $t1 = $text;
    # Recombine backspace chars with the chars they deleted. 
    # Loop recursive regex until all gone. 
    while (
        $matches = $text      =~ s/[^(\b)](?R)?[\b]//g  # no semi here!
    ) {1};
    
my $t2 = $text;
    # Recognize and strip out prompt.
    if ( $text      =~ s/(^.*[\$#]\s)// ) {
        $prompt     = $1;
    };
    
my $t3 = $text;
    # Discard BEL characters.
    $text       =~ s/(?:$bel)+//g;
    
    
    
##### 0: $t0
##### 1: $t1
##### m: $matches
##### 2: $t2
##### 3: $t3
##### X: $text
##### $: $prompt
    
    
    return 1;
}; ## _parse_script




# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# scratch echo sub
sub test_echo {
#### @_    
    my $terminal    = shift;
    my $self        = shift;
#~     my $parms       = shift;
#~     my $self        = shift @$parms;
#~     my $data        = shift @$parms;
### $terminal
### $self
    
    my $row_count   = $terminal->get_row_count();
### $row_count
#~     return FALSE
#~         if $self->{-row_count} == $row_count;   # number of lines unchanged
    
    my $old_row     = $self->{-row_count};
    my $new_row     = $row_count;
    my $max_col     = 80;
    
#~     my $start_row   = $old_row;
#~     my $end_row     = $new_row;
    my $start_row   = 0;
    my $end_row     = 1;
    my $start_col   = 0;
    my $end_col     = $max_col;
    
    
    my @list        = $terminal->get_text_range(
                        $start_row,             # start row
                        $start_col,             # start col
                        $end_row,               # end row
                        $end_col,               # end col
                        \&dummy,                # callback
                                                # callback argument
                    );
    my $text        = $list[0];
### $text
    
    
    $self->{-row_count}     = $row_count;
    return FALSE;       # propagate this signal
};

sub dummy {1};
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


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
#   quit($cs);     # short
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
sub quit {
    my $cs                  = shift;
    
    # Exit all terminal subshells that were created programmatically...
    # ... if there are any subshells registered in the football.
    if ( 
           defined   $cs->{-term_with_subshell} 
        && scalar @{ $cs->{-term_with_subshell} } 
    ) {
        my   @term_with_subshell    = @{ $cs->{-term_with_subshell} };
        for (@term_with_subshell) {
            my $terminal    = $_;
            my $feed        = "exit\n";     # shell 'exit' command
            $terminal->feed_child($feed);
        };
    };
    sleep(1);       # Wait a little to allow stuff to settle down. 
    
    # Delete any fifo "named pipes". 
#### $cs
    if (   defined   $cs->{-fifos} 
        && scalar @{ $cs->{-fifos} }
    ) {
        for ( @{ $cs->{-fifos} } ) {
            my $fifo            = $_;
            my $return_value    = `unlink $fifo`;
            # TODO: This doesn't catch the warning.
            warn "Failed to unlink $fifo: $return_value $?" 
                if $return_value || $?;
        };
    };
    
    # Reap zombies, if any.
#### $cs
    if (   defined   $cs->{-child_pid} 
        && scalar @{ $cs->{-child_pid} }
    ) {
        for ( @{ $cs->{-child_pid} } ) {
            my $pid             = $_;
            _reap_bloody( $cs, $pid );      # reap child; kill it if needed 
        };
    };
    
    
    
    # Quit from main loop and do Gtk2 cleanup.
    Gtk2->main_quit;
    
    return TRUE;        # do not propagate this signal
}; ## quit

#=========# INTERNAL ROUTINE
#
#   _reap_bloody( $cs, $pid );     # reap child; kill it if needed
#       
# Purpose   : Try to reap the child; 
#               if this fails, sleep a little and try again; 
#               if it still won't reap, kill it, reap it, and emit a warning. 
# Parms     : $cs           : football
#             $pid          : process ID of child to reap
# Reads     : ____
# Returns   : ____
# Writes    : ____
# Throws    : warns if it had to kill the child
# See also  : _quit()
# 
# ____
# 
sub _reap_bloody {
    my $cs              = shift;
    my $pid             = shift;
    my $max_wait        = 5;    # number of times && seconds to wait
    my $return_value    ;
    my $kill_signal     = 'KILL';
    
    # Try reaping a few times.
    for (0..$max_wait) {
        $return_value    = waitpid( $pid, WNOHANG );
        last if ( $return_value == $pid );   #successful reap
        sleep(1);
    }; ## for $max_wait
    
    # If successful, return; we're done. 
    return $pid if ( $return_value == $pid );
    
    # Kill stubborn child. 
    kill $kill_signal, $pid;
    warn "Had to kill $pid: $return_value $!";
    sleep(1);
    
    # Now reap it for sure. (?)
    $return_value    = waitpid( $pid, WNOHANG );    
    if ( $return_value != $pid ) {  # stubborn child didn't reap!
            warn "Failed to reap $pid: $return_value $!";
            return 0;                       # unsuccessful reap
    };
    
    return 1;                               # bloody reap
}; ## _reap_bloody

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
