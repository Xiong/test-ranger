package Test::Ranger;

use strict;
use warnings;
use Carp;

use version 0.77; our $VERSION = qv('0.0.1');

use Test::More;

## use

#============================================================================#

######## CLASS METHOD ########
#
#   my $obj = Test::Hump->new();
#
#       Returns a hashref blessed into class of calling package
#
#       see also: init();
#
sub new {
    my $class   = $_[0];
    my $self    = {};
    
    bless ($self => $class);
    $self->init(@_);            # init all remaining args
    
    return $self;
}; ## new

######## OBJECT METHOD ########
#
#   $obj->init( $AoH );
#
#       Initializes $obj with a preconstructed data structure.
#       $obj is a conventional hash-based object.
#       See docs for specification.
#
sub init {
    my $self    = $_[0];
    my $aref    = $_[1];
    
    # assign list to hash
    $self->{-data}      = $aref;
    
    return $self;
}; ## init

######## OBJECT METHOD ########
#
#   $test->execute();
#
#       Executes the tests and subtests defined in the object $test.
#
sub execute {
    my $self    = $_[0];
    
    pass('DUMMY');
    done_testing(1);
    
    return 1;                           # DUMMY
    
}; ## execute

#############################
######## END MODULE #########
1;
__END__

=head1 NAME

Test::Ranger - Test with data tables, capturing, templates

=head1 VERSION

This document describes Test::Ranger version 0.0.1

NOTE: THIS IS A DUMMY, NONFUNCTIONAL RELEASE.

=head1 SYNOPSIS

    # Object-oriented usage
    use Test::Ranger;

    my $test    = Test::Ranger->new(
        {
            -coderef    => \&Acme::Dummy::hello_mult,
            -basename   => 'hello-mult',
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
        
    ); ## end new

    $test->execute();

=head1 DESCRIPTION

=over

I<The computer should be doing the hard work.> 
I<That's what it's paid to do, after all.>
-- Larry Wall

=back

This is a comprehensive testing module compatible with Test::More and friends 
within TAP::Harness. Helper scripts and templates are included to make 
test-driven development quick, easy, and reliable. Test data structure is 
open; choose from object-oriented methods or procedural/functional calls. 

Tests themselves are formally untestable. All code conceals bugs. Do you want 
to spend your time debugging tests or writing production code? 
The Test::Ranger philosophy is to reduce the amount of code in a test script 
and let test data (given inputs and wanted outputs) dominate. 

Many hand-rolled test scripts examine expected output to see if it matches 
expectations. Test::Ranger traps fatal exceptions cleanly and makes it easy 
to subtest every execution for both expected and unexpected output. 

=head2 Approach

Our overall approach is to declare all the conditions for a series of 
tests in an Array-of-Hashes. We loop through the tests, supplying inputs 
to code under test and capturing outputs within the same AoH. Then we check 
each execution's actual outputs with what we expected. 

Each test is represented by a hashref in which each key is a literal string; 
the values may be thought of as attributes of the test. The literal keys are 
part of our published interface; accessor methods are not required. 

Test::Ranger does not lock you in to a single specific approach. You can 
declare your entire test series as an object and simply execute it, 
letting TR handle the details. You can read your data from somewhere 
and just use TR to capture a single execution, then examine the results 
on your own. You can mix TR methods and function calls; you can add 
other Test::More-ish checks. The door is open.

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

=head3 group

Array of (several sequential) test L<declarations|/declaration>

=head3 declaration

The data required to execute a test, 
including given L</inputs> and expected L</outputs>

=head3 execution

The process of running a test L</declaration> and capturing actual L</outputs>

=head3 subtest

For an execution, a single comparison of actual and expected 
results for some output. 

Note that a C<Test::More::subtest()>, used internally by Test::Ranger, 
counts as a single 'test' passed to harness. In these docs, a 'subtest' is 
any one comparison within a call to C<subtest()>. 

=head3 inputs

Besides arguments passed to SUT, any state that it might read, 
such as C<@ARGV> and C<%ENV>. 

Inputs are I<given>, perhaps I<generated>. 

=head3 outputs

Besides the conventional return value, anything else SUT might write, 
particularly STDOUT and STDERR; also includes exceptions thrown by SUT.

Outputs may be I<actual> (L</-got>) or I<expected> (L</-want>).

=head3 CUT, SUT, MUT

code under test, subroutine..., module...; the thing being tested




=head1 INTERFACE 

The primary interface to TR is the test data structure you normally supply 
as the argument to L</new()>. There are also a number of methods you can use. 
In Perl, methods can be called as functions; Test::Ranger's methods 
are written with this in mind.

=head2 $test

You can call this anything you like, of course. 
If you pass a hashref to the constructor L<Test::Ranger::new()|/new()>, 
it will return an object blessed into class B<Test::Ranger>; 
if you pass an arrayref of hashrefs, it will bless each hashref into the 
base class, wrap the arrayref in a top-level hashref, and bless the mess 
into L<Test::Ranger::List>. 

The B<Test::Ranger> object represents a single test L</declaration>. 
Besides the data that you provide, it contains test outputs 
and some housekeeping information. All data is kept in essentially 
the same structure you pass to the constructor. You should use the following 
literal hash keys to access any element or object attribute: 

=over




=back



=head2 Methods

=head3 new()




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
