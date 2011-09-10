package Test::Ranger::CS;       # pseudo-global football of state

use 5.010000;
use strict;
use warnings;
use Carp;

use version 0.89; our $VERSION = qv('v0.0.4');

#use parent qw{  };             # inherits from UNIVERSAL only

use Scalar::Util qw(
    looks_like_number
);
#    weaken isweak reftype refaddr blessed isvstring readonly tainted 
#    dualvar looks_like_number openhandle set_prototype 
use List::MoreUtils qw(
    any all none notall
);
#    any all none notall true false firstidx first_index 
#    lastidx last_index insert_after insert_after_string 
#    apply after after_incl before before_incl indexes 
#    firstval first_value lastval last_value each_array
#    each_arrayref pairwise natatime mesh zip uniq minmax

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
use IO::File;

use Data::Dumper;               # value stringification toolbox

# gtk-perl modules; see http://gtk2-perl.sourceforge.net/doc/pod/
use Gtk2;                       # Gtk+ GUI toolkit : Do not -init in modules!
use Glib                        # Gtk constants
    'TRUE', 'FALSE',
; ## Glib

# use for debug only
use Devel::Comments '###';      # debug only                             #~

$::Debug = 0 unless (defined $::Debug);     # global; can be raised in caller

######## CLASS METHOD ########
#
#   my $obj = Test::Ranger::CS->new();
#
#       Returns a hashref blessed into class of calling package
#
#       Args are optional but if supplied must be a list of 
#        key/value pairs, which will be used to initialize the object.
#
#       see also: init();
#
sub new {
    my $class   = shift;
    my $self    = {};
    
    bless ($self => $class);
    $self->init(@_);            # init all remaining args
    
    return $self;
};
######## /new ########

######## OBJECT METHOD ########
#
#   $obj->init( '-key' => $value, '-foo' => $bar );
#
#       initializes $obj with a list of key/value pairs
#       empty list okay
#
sub init {
    my $self    = shift;
    my @args    = @_;
    
    # do some minimal checking
    _crash('init_0') if ( scalar @args % 2 );
    
    # assign list to hash
    %{ $self }  = @args;
    
    return $self;
};
######## /init ########

#=========# OBJECT METHOD
#
#   $cs->get_config( 'all' );     # get configurations from files
#       
# Purpose   : ____
# Parms     : ____
# Reads     : ____
# Returns   : ____
# Invokes   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
#   
sub get_config {
    my $cs              = shift;
    my %config          ;
    
    # Figure out the four possible config file paths.
    my $folder_name     = 'test-ranger';
    my $default_name    = 'default_config';
    my $file_name       = 'config.perl';
    my $system_folder   = 'etc';
    my $user_folder     = q{.} . $folder_name;
    my $project_folder  = q{.} . $folder_name;
    my $rootdir         = File::Spec->rootdir();
    my $homedir         = $ENV{'HOME'};
    my $currentdir      = getcwd();
    
    my @paths           ;
    
    push @paths,    File::Spec->catfile(        # defaults
                            $rootdir,
                            $system_folder,
                            $folder_name,
                            $default_name 
                    ),
    
                    File::Spec->catfile(        # system-wide
                            $rootdir,
                            $system_folder,
                            $folder_name,
                            $file_name 
                    ),
                    
                    File::Spec->catfile(        # user
                            $homedir,
                            $user_folder,
                            $file_name 
                    ),
                    
                    File::Spec->catfile(        # project
                            $currentdir,
                            $project_folder,
                            $file_name 
                    ),
                    
    ; ## push
    
    # Store paths in football.
    $cs->{-config_paths}    = \@paths; 
    
    # For each path, load the file if exists.
    for (@paths) {
        my $path        = $_;
#### Loading config file: $path
        my $fh = IO::File->new("< $path")
            or next;            # not a problem if no config file found
        my $prev_fh         = select $fh;
        local $/            = undef;            # slurp
        select $prev_fh;
        my $file_contents   = <$fh>;
#### $file_contents
        my %temp            = eval $file_contents;
        _crash( 'get_config_0', $path, q{}, $@ ) if $@;    
#### %temp
        
        %config             = ( %config, %temp );
#### %config
#### '------'
        
        
        close $fh;
    };
    # ... but it's bad if no configuration found at all.
    _crash( 'get_config_1', @paths, q{} ) if ( not scalar keys %config );    
    
#### Configuration: %config    
    
    # Store configuration.
    $cs->{-config}          = \%config;
    return $cs;
    
}; ## get_config

#=========# OBJECT METHOD
#
#   $cs->get_pane($frame_number);     # get the pane in the frame
#       
# Purpose   : ____
# Parms     : ____
# Reads     : ____
# Returns   : ____
# Invokes   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# Find the pane currently inside a given frame, by frame number.
#   
sub get_pane {
    my $cs              = shift;
    my $frame_number    = shift;
    my @frames          = @{ $cs->{-frames} };
#### @frames
    
    # Frames are numbered in order of creation.
    my $frame           = $frames[$frame_number]
        or _crash( 'get_pane_0', "frame_number: $frame_number" );
    
    # Find the VBox, which is the requested pane.
    my $pane        = $frame->get_child();    
#### $pane
    
    return $pane;
}; ## get_pane

#=========# OBJECT METHOD
#
#   $cs->get_color_of( $color_spec );     # string, number, or arrayref
#       
# Purpose   : Turns an ill-behaved color spec into a well-behaved one.
# Parms     : $cs           : self
#           : $color_spec   : string, number, or arrayref
# Reads     : ____
# Returns   : $color        : Gtk2::Gdk::Color
# Invokes   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# The legitimate Gtk2::Gdk::Color object is an array of four elements; 
#   each element must be an integer in the range 0..0xffff (0..65535).
# This array is [ R, G, B, x ] where x is, so far, unknown and can be undef. 
#   
# This method converts various kinds of arguments into such an object.
# Acceptable arguments: 
#   '-some_thing'       Get from config file(s)
#   [ $r, $g, $b ]      Directly specify each value
#   'name'              Specify using a named color defined in method
#   RGB                 Shorthand CSS-like spec; three hex digits
#
sub get_color_of {
    my $cs              = shift;
    my $color_spec      = shift;
    my $hex             = qr/[0-9]|[a-f]|[A-F]/;   # match valid hex digit
    my $max             = 0xffff;   # top of range is C double
    my $lit             = 0xbbbb;   # a light shade
    my %named_color     = (
    #   'name'                   Red        Green       Blue        ??
        'white'             => [ $max,      $max,       $max,       0 ],
        'black'             => [ 0,         0,          0,          0 ],
        'red'               => [ $max,      0,          0,          0 ],
        'green'             => [ 0,         $max,       0,          0 ],
        'blue'              => [ 0,         0,          $max,       0 ],
        'cyan'              => [ 0,         $max,       $max,       0 ],
        'mauve'             => [ $max,      $lit,       $max,       0 ],
        'straw'             => [ $max,      $max,       $lit,       0 ],
        'gray'              => [ $lit,      $lit,       $lit,       0 ],
    );
    my $color           ;
#     my $color           = Gtk2::Gdk::Color->new(0, 0, 0, 0);
    
#### $color_spec
    if ( substr ($color_spec, 0, 1) eq '-' ) {    # requested from config hash
        _crash( 'get_color_of_1', $color_spec, '') 
            if not defined $cs->{-config}{$color_spec};
#### $cs->{-config}{$color_spec};
        # recursive call
        $color  = $cs->get_color_of( $cs->{-config}{$color_spec} );
    }
    elsif ( ref $color_spec eq 'ARRAY' ) {                  # array of...
        my @ary = @$color_spec;
        
        # check validity of each element
        for (@ary) {
            # can I do arithmetic on this element?
            _crash( 'get_color_of_2', $color_spec, $_, '') 
                if not looks_like_number($_);
            # is element within range?
            _crash( 'get_color_of_2', $color_spec, $_, '') 
                if not ( $_ >= 0 and $_ <= $max );          #   0..$max
        };
        
        # okay
        $color   = Gtk2::Gdk::Color->new(@ary);
    }
    elsif ( defined $named_color{$color_spec} ) {   # named in method
        $color   = Gtk2::Gdk::Color->new( @{ $named_color{$color_spec} } );
    }
    elsif ( $color_spec =~ m/($hex)($hex)($hex)/ ) {  # looks like CSS...
        # expand 'f' to 'ffff' = 65535
        my $r   = hex $1 x 4;
        my $g   = hex $2 x 4;
        my $b   = hex $3 x 4;
        $color   = Gtk2::Gdk::Color->new( $r, $g, $b, 0 );        
    }
    else {
        _crash( 'get_color_of_0', $color_spec );
    };
    
    return $color;
}; ## get_color_of

#=========# OBJECT METHOD
#
#   $obj->method( '-parm' => $value, );     # short
#       
# Purpose   : ____
# Parms     : ____
# Reads     : ____
# Returns   : ____
# Invokes   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
#   
sub method {
    
    
    
}; ## method

######## INTERNAL UTILITY ########
#
#   _crash( $errkey, @more );      # fatal out of internal error
#       
# Calls croak() with some message. 
#   
sub _crash {
    my $errkey      = shift;            # remaining args are more lines
    my $prepend     = __PACKAGE__;      # prepend to all errors
       $prepend     = join q{}, q{# }, $prepend, q{: };
    my $indent      = qq{\n} . q{ } x length $prepend;
    
    my @lines       ;
    my $text        ;
    
    # define errors
    my $error       = {
        init_0          => [ 
            'Odd number of args in init()', 
        ],
        get_config_0    => [
            'Error evaluating config file:',
        ],
        get_config_1    => [
            'No config file found; searched:',
        ],
        get_pane_0      => [
            'Tried to get a nonexistent pane:',
        ],
        put_mw_0        => [
            'Tried to store main Window from an undefined reference',
        ],
        put_mw_1        => [
            'Not a main Window',
        ],
        put_mw_2        => [
            'Not a Gtk object',
        ],
        get_color_of_0  => [
            'Bad color specification',
        ],
        get_color_of_1  => [
            'No color specification in configuration',
        ],
        get_color_of_2  => [
            'Color specification not arrayref of \'double\' integers',
        ],
    };
    
    # find and expand error
    if ($errkey) {
        push @lines, $errkey;
        push @lines, @{ $error->{$errkey} };
    }
    else {
        push @lines, 'Unimplemented error';
    };
    push @lines, @_;
    $text           = $prepend . join $indent, @lines;
    
    # now croak()
    croak $text;
    return 0;                   # should never get here, though
};
######## /_crash ########

#============================================================================#

# CS is a 'sloppy' hashref class in which callers are expected to stuff 
# things in and take them out directly. It's expected that only one such 
# object will exist per script invocation. I call it a "football" because 
# it's passed from hand to hand; nothing can be done by anything that has 
# not got it. I call it "pseudo-global" because it contains values that are, 
# essentially, global to all execution. 
#
# LIST KEYS HERE:
# 
# -mw                           # Gtk main Window object
# -config                       # basic configurations loaded from file
#   -mw_initial_V               # main Window starting size Vertical   (px)
#   -mw_initial_H               # main Window starting size Horizontal (px)
#   -mw_anchor                  # where main Window is anchored on screen

#=========# OBJECT METHOD
#
#   $mw = $cs->get_mw();        # retrieve the Gtk main Window object
#       
# Purpose   : Copy main Window object from football into supplied ref.
# Reads     : $cs
# Writes    : $mw
# Throws    : ____
# See also  : put_mw()
# 
sub get_mw {
    my $cs          = shift;
    my $mw          = $cs->{ -mw };
        
    return $mw;
}; ## get_mw

#=========# OBJECT METHOD
#
#   $cs->put_mw( $mw );     # store the Gtk main Window object
#       
# Purpose   : Copy main Window object from supplied ref into football.
# Parms     : $mw
# Writes    : $cs
# Throws    : if no $mw given or $mw is not a valid Gtk object 
# See also  : get_mw()
#
# There is no need to repeatedly put_mw($mw); the ref is stored. 
# Call this method once only after main Window creation.
#   
sub put_mw {
    my $cs          = shift;
    my $mw          = shift;
    
#### $mw    
    # $mw must be a defined reference
    _crash( 'put_mw_0' ) if not defined $mw;
    
    # $mw must be a Gtk main Window
#~     TODO: is this a valid Gtk main Window?
#~     _crash('put_mw_1') if not ( $mw = eval{ $mw->MainWindow(); } );
    _crash( 'put_mw_2', $@ ) if $@;    
    
    $cs->{ -mw }    = $mw;
    
    return $cs;
}; ## put_mw









#############################
######## END MODULE #########
1;
__END__

=head1 NAME

Test::Ranger::CS - class for 'context structure' football


=head1 VERSION

This document describes Test::Ranger::CS version 0.0.4


=head1 SYNOPSIS

    use Test::Ranger::CS;
    $cs             = Test::Ranger::CS->new;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

Since C<< test-ranger >> is a GUI application, a great deal of state must be
stored for any instance of it while it is running. We could use a number of 
global variables (if we were nasty) or some lexicals scoped to the main 
package (e.g., $::Thingy) if we were somewhat less nasty. Somewhat better, we 
store all this state in key/value pairs of a big hashref; we then pass this 
around, like a football, to all our routines. 

Test::Ranger::CS implements the pseudo-global football as an object. 

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< init_0 >>

You probably called the C<< new() >> method with an odd number of arguments. 
If you want to initialize a T::R::CS object, you need to pass an array of 
key/value pairs (not an array reference); this will be converted into a hash.

=item C<< put_mw_0 >>

Call Gtk2::Window->new() before trying to store $mw in the football. 

=item C<< put_mw_1 >>

You tried to store the wrong Gtk object; put_mw() is only useful with 
the main Window. 

=item C<< put_mw_2 >>

You really tried to store the wrong thing. 

[Et cetera, et cetera]

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
  
Test::Ranger::CS requires no configuration files or environment variables.

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

No bugs have been reported.

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
