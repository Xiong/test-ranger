package Test::Ranger::Shell;

use 5.010000;
use strict;
use warnings;
use Carp;

use version 0.77; our $VERSION = qv('v0.0.4');

use Data::Lock qw( dlock );     # Declare locked scalars, arrays, and hashes
use Scalar::Util;               # General-utility scalar subroutines
use Scalar::Util::Reftype;      # Alternate reftype() interface


## use

# Alternate uses
#~ use Devel::Comments;

#============================================================================#

# Constants

#~ # Literal hash keys
#~ dlock( my $coderef     = '-coderef');    # cref to code under test

#----------------------------------------------------------------------------#


## END MODULE
1;
#============================================================================#
__END__

=head1 NAME

Test::Ranger::Shell - Tag tests and manage tagged sets of tests

=head1 VERSION

This document describes Test::Ranger::Shell version v0.0.4

=head1 SYNOPSIS

    # Enter the Test::Ranger interactive shell
    
    user@host:~/projects/myproject$ trish
    #: user@host:~/projects/myproject$
    
    
    

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

Copyright (C) 2010 Xiong Changnian C<< <xiong@cpan.org> >>

This library and its contents are released under Artistic License 2.0:

L<http://www.opensource.org/licenses/artistic-license-2.0.php>

=cut
