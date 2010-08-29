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
#	my $obj	= Test::Hump->new();
#
#		Returns a hashref blessed into class of calling package
#
#		see also: init();
#
sub new {
	my $class	= $_[0];
	my $self	= {};
	
	bless ($self => $class);
	$self->init(@_);			# init all remaining args
	
	return $self;
}; ## new

######## OBJECT METHOD ########
#
#	$obj->init( $AoH );
#
#		Initializes $obj with a preconstructed data structure.
#		$obj is a conventional hash-based object.
#		See docs for specification.
#
sub init {
	my $self	= $_[0];
	my $aref	= $_[1];
	
	# assign list to hash
	$self->{-data}	    = $aref;
	
	return $self;
}; ## init

######## OBJECT METHOD ########
#
#	$test->execute();
#
#		Executes the tests and subtests defined in the object $test.
#
sub execute {
	my $self	= $_[0];
    
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
            -coderef	=> \&Acme::Dummy::hello_mult,
            -basename	=> 'hello-mult',
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
