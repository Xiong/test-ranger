package Test::Ranger::Script;

use 5.010000;
use strict;
use warnings;
use Carp;

use version 0.89; our $VERSION = qv('v0.0.4');

use Test::Ranger::CS;           # pseudo-global football of state

use Data::Lock qw( dlock );     # Declare locked scalars, arrays, and hashes
use List::MoreUtils qw(
    any all none notall true false firstidx first_index 
    lastidx last_index insert_after insert_after_string 
    apply after after_incl before before_incl indexes 
    firstval first_value lastval last_value each_array
    each_arrayref pairwise natatime mesh zip uniq minmax
);

use Tk;                         # GUI toolkit

## use

# Alternate uses
#~ use Devel::Comments;

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
# See also  : _setup()
# 
# This is intended to be called from an invocating script. 
# It runs once, calling all needed routines. 
# State is stored in $cs, the "pseudo-global football" passed around. 
# So $cs is a big hash; an object of class Test::Ranger::CS. 
# Generally, all routines in this module expect $cs as a param and return it. 
# 
sub main {    
    my $tk          ;                       # Tk MainWindow object
    my $cs          ;                       # my pseudo-global football
    
    # Create the football
    $cs             = Test::Ranger::CS->new;
    
    # Create the MainWindow
    $tk             = MainWindow->new;
    $tk-> geometry( '800x800' );            # enforce starting size
    $cs->put_tk( $tk );                     # store the Tk MainWindow object
    
    _setup($cs);
    MainLoop;
    
    return $cs;
}; ## main

#=========# TK SETUP METHOD
#
#   _setup($cs);
#       
# Purpose   : Set up all Tk stuff. Main method.
# Parms     : $cs
# Reads     : ____
# Returns   : $tk
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
# 
sub _setup {
    my $cs          = shift;
    my $tk          = $cs->get_tk();
    
    # MainWindow title
    $tk->title("Test Ranger");
    
    # Menu bar
    _setup_menus($cs);      # initial menus on launch
    
    # Panes
    _setup_panes($cs);      # initial window panes
    
    
    
#~     # Emergency exit button
#~     my $exit_button ;
#~     $exit_button    = $tk->Button(
#~         -text => "Exit", -command => \&_exit
#~     );
#~     $exit_button->pack;
    
#~     # demo grab keysym -- debug only
#~     $tk->bind('<KeyPress>' => \&print_keysym);
#~     sub print_keysym {
#~         my($widget) = @_;
#~         my $e = $widget->XEvent;    # get event object
#~         my($keysym_text, $keysym_decimal) = ($e->K, $e->N);
#~         print "keysym=$keysym_text, numeric=$keysym_decimal\n";
#~     };

    
    return $cs;
}; ## _setup

#=========# TK SETUP METHOD
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
    my $cs          = shift;
    my $tk          = $cs->get_tk();
    
    my $menubar         ;
    
    my $file_menu       ;
    my $file_menu_items =[
        [ command => 'Quit', 
            -command        => \&_exit, 
            -accelerator    => 'Ctrl-Q', 
        ],
    ];
    $tk->bind('<Control-q>' => \&_exit);
    
    my $edit_menu       ;
    my $edit_menu_items ;
    
    my $help_menu       ;
    my $help_menu_items ;
    
    # Entire main menubar
    $tk->configure(-menu => $menubar = $tk->Menu);
    $file_menu   = $menubar->cascade(-label => '~File', 
        -menuitems => $file_menu_items
    );
    $edit_menu   = $menubar->cascade(-label => '~Edit',
        -menuitems => $edit_menu_items
    );
    $help_menu   = $menubar->cascade(-label => '~Help',
        -menuitems => $help_menu_items
    );

    return $cs;
}; ## _setup_menus

#=========# TK SETUP METHOD
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
    my $tk          = $cs->get_tk();
    
    my $sash1           ;       # outer, horizontal sash
    my $sash2           ;       # inner, vertical sash (top)
    
    my $pane1           ;       # left
    my $pane2           ;       # right
    my $pane3           ;       # bottom
    
    # 'vertical' pane orientation means a horizontal sash
    $sash1              = $tk->Panedwindow( -orient => 'vertical' );
    $sash1->pack(
        -side       => 'top',
        -expand     => 'yes',
        -fill       => 'both',
        -padx       => 2,
        -pady       => 2,
    );
    
    # $sash2 fills the top area within $sash1
    $sash2              = $sash1->Panedwindow;
    $sash2->pack(
        -side       => 'top',
        -expand     => 'yes',
        -fill       => 'both',
        -padx       => 2,
        -pady       => 2,
    );
    
    # top left is child of $sash2
    $pane1              = $sash2->Label(
                            -text       => 'left',
                            -background => 'yellow',
                        );
    
    # top right is child of $sash2
    $pane2              = $sash2->Label(
                            -text       => 'right',
                            -background => 'cyan',
                        );
    
    # bottom is child of $sash1
    $pane3              = $sash1->Label(
                            -text       => 'bottom',
                            -background => 'red',
                        );
    
    $sash2->add( $pane1, $pane2 );
    $sash1->add( $sash2, $pane3 );
        
    return $cs;
}; ## _setup_panes

#=========# TK SETUP METHOD
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
    my $tk          = $cs->get_tk();
    
    
    return $cs;
}; ## _do_

#=========# INTERNAL ROUTINE
#
#   _exit();     # short
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
sub _exit {
    
    exit;
    
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
