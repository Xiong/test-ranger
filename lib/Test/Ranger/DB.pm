package Test::Ranger::DB;       # database interactions

use 5.010000;
use strict;
use warnings;
use Carp;

use version 0.89; our $VERSION = qv('v0.0.4');

use parent 'Test::Ranger::CS';  # just for new() and init() methods

use DBI;                # Generic interface to a large number of databases
#~ use DBD::mysql;         # DBI driver for MySQL
use DBD::SQLite;        # Self-contained RDBMS in a DBI Driver
use DBIx::RunSQL;       # run SQL to create a database schema

# use for debug only
use Devel::Comments '###';      # debug only                             #~



#============================================================================#

#----------------------------------------------------------------------------#

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
        unpaired            => [ 
            'Unpaired argument in call to...', 
        ],
        create_1            => [
            'No SQL file passed to create()',
        ],
    };
    
    # find and expand error
    if ( $errkey && defined $error->{$errkey} ) {
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

#=========# OBJECT METHOD
#
#   $msg    = $db->create( 
#               -db_name    => 'tr',        # (file)name of sqlite database
#               -sql_file   => 'setup.sql', # setup file contains SQL syntax
#               -verbose    => 1,           # print each SQL statement as run
#           );
#       
# Purpose   : Create a 'tr' database if it does not exist.
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
sub create {
    my $db          = shift;
    _crash 'unpaired', 'create()', @_, $! 
        if ( scalar @_ % 2 );       # an even number modulo 2 is zero: false
    my %args        = @_;
    my $db_name     = $args{-db_name};
#~     my $user        = $args{-db_user};      # not supported by SQLite
#~     my $pass        = $args{-db_pass};      # not supported by SQLite
    my $sql_file    = $args{-sql_file}
        or _crash 'create_1', $!;
    my $verbose     = $args{-verbose};
    
    my $msg         ;
    
    my $dsn         = "DBI:SQLite:$db_name";
    my $dbh         = DBIx::RunSQL->create(
                dsn     => $dsn,
                sql     => $sql_file,
                verbose => $verbose,
    );
    
    $msg            = 'Database Created.';      # fake only for debug only
    return $msg;
}; ## create



## END MODULE
1;
#============================================================================#
__END__

=head1 NAME

Test::Ranger::DB - Database interactions for Test-Ranger

=head1 VERSION

This document describes Test::Ranger::DB version 0.0.4

=head1 SYNOPSIS

    use Test::Ranger::DB;
    $db             = Test::Ranger::DB->new;    # just a handle
    $db->create(                                # create database
            -
        );




=head1 DESCRIPTION

Test::Ranger::DB manages all interactions with the underlying database. 
The database contains persistent information about user's project; it does 
not contain C<< test-ranger >> tool configuration. 

The primary purpose of the OO module structure is to allow OO calling 
and avoid namespace pollution. The TR::DB object does not represent the 
entire database but only those tables that concern the current project. 

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

=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
Test::Ranger::DB requires no configuration files or environment variables.

=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

Test::Ranger::DB requires MySQL to be installed and running.

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

