package Test::Ranger::Base;     # Base class and procedural utilities

use 5.010001;
use strict;
use warnings;
use Carp;

use version 0.94; our $VERSION = qv('0.0.4');

use Data::Lock qw( dlock );     # Declare locked scalars
use Scalar::Util;               # General-utility scalar subroutines
use Scalar::Util::Reftype;      # Alternate reftype() interface

use Exporter::Easy (            # Procedural as well as OO interface; you pick
    TAGS    => [
        util        => [qw{
            crash
            crank
            paired
            
        }],
                
        all         => [qw{ :util :test }]
    ],
);

## use

# Alternate uses
#~ use Devel::Comments '#####', ({ -file => 'tr-debug.log' });

#============================================================================#

# Pseudo-globals

# Error messages
dlock( my $err     = Test::Ranger->new(  # this only locks the reference
    _unpaired   => [ 'Unpaired arguments passed; named args required:' ],
    _unsupported_akin   => 
        [ 'akin() does not support refs except SCALAR and ARRAY.' ],
    
) ); ## $err

#----------------------------------------------------------------------------#

#=========# OBJECT METHOD OR EXTERNAL ROUTINE
#
#    crash( @lines );                # fatal out with @lines message
#    $tr->crash( @lines );           # OO interface
#    $tr->crash( $errkey );          # fatal out with value of $errkey
#    $tr->crash( $errkey, @lines );  # fatal out with additional @lines
#
# Purpose   : Fatal out of internal errors
# Parms     : $errkey   : string    : must begin with '_' (underbar)
#             @lines    : strings   : free text
# Reads     : $tr->{$errkey}, $tr->{-error}{$errkey}
# Returns   : never
# Throws    : always die()-s
# See also  : paired(), crank()
# 
# The first arg is tested to see if it's a reference and if so, shifted off.
# Then the next test is to see if the second (now first) arg is an errkey.
# If not, then all args are considered @lines of text.
#   
sub crash {
    my $self        ;
    my @lines       ;
    my $text        ;
    if ( ref $_[0] ) {              # first arg is a reference
        $self       = shift;        # hope it's blessed
        if ( $_[0] =~ /^_/ ) {      # an $errkey was provided
            my $errkey      = shift;
##### $errkey    
            # find and expand error
            if ( defined $self->{$errkey} ) {
                push @lines, $errkey;
                push @lines, @{ $self->{$errkey} };
            }
            else {
                push @lines, "Unimplemented error $errkey";
            };
        };
    };
    push @lines, @_;                # all remaining args are error text.
        
    # Stack backtrace.
    my $call_pkg        = 0;
    my $call_sub        = 3;
    my $call_line       = 2;
    for my $frame (1..3) {
        my @caller_ary  = caller($frame);
        push @lines,      $caller_ary[$call_pkg] . ( q{ } x 4 )
                        . $caller_ary[$call_sub] . q{() line }
                        . $caller_ary[$call_line]
                        ;
    };
    
    my $prepend     = __PACKAGE__;      # prepend to all errors
       $prepend     = join q{}, q{# }, $prepend, q{: };
    my $indent      = qq{\n} . q{ } x length $prepend;
    
    # Expand error.
    $text           = $prepend . join $indent, @lines;
    $text           = $text . $indent;      # before croak()'s trace
    
    # now croak()
    croak $text;
    return 0;                   # should never get here, though
}; ## crash

#=========# EXTERNAL FUNCTION
#
#   my %args    = paired(@_);     # check for unpaired arguments
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
sub paired {
    if ( scalar @_ % 2 ) {  # an odd number modulo 2 is one: true
        $err->crash('_unpaired');
    };
    return @_;
}; ## paired

#=========# CLASS METHOD
#
#   my $obj     = $class->new();
#   my $obj     = $class->new({ -a  => 'x' });
#       
# Purpose   : Object constructor
# Parms     : $class    : Any subclass of this class
#             anything else will be passed to init()
# Returns   : $self
# Invokes   : init()
# 
# If invoked with $class only, blesses and returns an empty hashref. 
# If invoked with $class and a hashref, blesses and returns it. 
# Note that you can't skip passing the hashref if you mean to init() it. 
# 
sub new {
    my $class   = shift;
    my $self    = {};           # always hashref
    
    bless ($self => $class);
    $self->init(@_);            # init remaining args
    
    return $self;
}; ## new

#=========# OBJECT METHOD
#   $obj->init( '-key' => $value, '-foo' => $bar );
#
#       initializes $obj with a list of key/value pairs
#       empty list okay
#
sub init {
    my $self    = shift;
    my @args    = paired(@_);
    
    # assign list to hash
    %{ $self }  = @args;
    
    return $self;
}; ## init


## END MODULE
1;
#============================================================================#
__END__

=head1 NAME

Test::Ranger - Testing tool base class and utilities

=head1 VERSION

This document describes Test::Ranger version 0.0.4

TODO: THIS IS A DUMMY, NONFUNCTIONAL RELEASE.

=head1 SYNOPSIS

    # Object-oriented usage
    use Test::Ranger;

    my $group    = Test::Ranger->new([
        {
            -coderef    => \&Acme::Teddy::_egg,
            -basename   => 'teddy-egg',
        },
        
        {
            -name       => '4*7',
            -given      => [ 4, 7 ],
            -return     => {
                -is         => 42,
            },
            -stdout     => {
                -like       => [ qw(hello world) ],
                -matches    => 2,
                -lines      => 1,
            },
        },
        
        {
            -name       => '9*9',
            -given      => [ 9, 9 ],
            -return     => {
                -is         => 81,
            },
        },
        
        {
            -name       => 'string',
            -given      => [ 'monkey' ],
            -warn       => {
                -like       => 'dummy',
            },
        },
        
    ]); ## end new

    $group->test();
    
    __END__

=head1 DESCRIPTION

=over

I<The computer should be doing the hard work.> 
I<That's what it's paid to do, after all.>
-- Larry Wall

=back



=head2 Approach



=head2 Templates

To further speed things along, please note that a number of templates 
are shipped with TR. These may be copied, modified, and extended as you 
please, of course. Consider them a sort of cookbook and an appendix to 
this documentation. 

=head1 GLOSSARY

I<You are in a maze of twisty little tests, all different.>

The word B<test> is so heavily overloaded that documentation may be unclear. 
In TR docs, I will use the following terms: 

=head3 manager

E.g., I<prove>, I<make test>; 
program that runs a L</suite> through a L</harness>

=head3 harness

E.g., L<Test::Harness> or L<TAP::Harness>; summarizes L</framework> results

=head3 framework

E.g., L<Test::Simple> or L<Test::More>; sends results to L</harness>

=head3 suite

Folder or set of test L<scripts|/script>.

=head3 script

File containing Perl code meant to be run by a L</harness>; 
filename usually ends in .t

=head3 list

Array or series of (several sequential) test L<declarations|/declaration>

=head3 declaration

The data required to execute a test, 
including given L</inputs> and expected L</outputs>; 
also, the phase in which this data is constructed

=head3 execution

The action of running a test L</declaration> and capturing actual L</outputs>;
also, the phase in which this is done

=head3 checking

The action of comparing actual and expected values for some execution; 
also, the phase in which this is done

=head3 subtest

A single comparison of actual and expected results for some output. 

Note that a C<Test::More::subtest()>, used internally by Test::Ranger, 
counts as a single 'test' passed to harness. In these docs, a 'subtest' is 
any one check within a call to C<subtest()>. 

=head3 inputs

Besides arguments passed to SUT, any state that it might read, 
such as C<@ARGV> and C<%ENV>. 

Inputs are I<given>, perhaps I<generated>. 

=head3 outputs

Besides the conventional return value, anything else SUT might write, 
particularly STDOUT and STDERR; also includes exceptions thrown by SUT.

Outputs may be I<actual> (L</-got>) results or I<expected> (L</-want>).

=head3 CUT, SUT, MUT

code under test, subroutine..., module...; the thing being tested

=head1 INTERFACE 

=head1 INSTALLATION

=head2 Testing Environmment

It is possible to control testing of Test::Ranger itself (and related modules) 
through the setting of several shell environment variables. You may wish to do 
this during C<< Build test >> or with C<< prove >>. Executing C<< prove -v >> 
will display additional diagnostics. 

These environment variables are respected I<only> during testing of TR: 

    tr_test_db_name='mydbfile'  # Will be created as an SQLite database
                                #   default: ':memory'
                                #       or possibly 'file/db/tr_test_01'
    tr_sql_file='some.sql'      # SQL will be used to create test DB
                                #   default: 'file/db/tr_db.sql'
    tr_preserve_test_db=1       # Preserve DB file on test script exit
                                #   default: unlinks DB file on exit
                                #   DB will always be unlinked on entry

=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

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

Copyright (C) 2010 Xiong Changnian C<< <xiong@cpan.org> >>

This library and its contents are released under Artistic License 2.0:

L<http://www.opensource.org/licenses/artistic-license-2.0.php>

=cut
