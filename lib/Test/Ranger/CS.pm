package Test::Ranger::CS;

use strict;
use warnings;
use Carp;

use version 0.89; our $VERSION = qv('v0.0.4');

#use parent qw{  };             # inherits from UNIVERSAL only

use Data::Dumper;               # value stringification toolbox

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

######## INTERNAL UTILITY ########
#
#   _crash( $errkey, @parms );      # fatal out of internal error
#       
# Calls croak() with some message. 
#   
sub _crash {
    my $errkey      = $_[0];            # remaining args replace placeholders
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
        
    };
    
    # find and expand error
    @lines          = @{ $error->{$errkey} };
    $text           = $prepend . join $indent, @lines;
    
    # now croak()
    croak $text;
    return 0;                   # should never get here, though
};
######## /_crash ########

#============================================================================#









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

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

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

=item C<< Odd number of args in init() >>

You probably called the C<< new() >> method with an odd number of arguments. 
If you want to initialize a T::R::CS object, you need to pass an array of 
key/value pairs (not an array reference); this will be converted into a hash.

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
