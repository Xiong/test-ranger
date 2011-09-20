package Test::Ranger::DB;       # database interactions

use 5.010001;
use strict;
use warnings;
use Carp;

use version 0.94; our $VERSION = qv('v0.0.4');

use parent qw{ Test::Ranger };
use Test::Ranger qw(:all);      # Testing tool base class and utilities

use DBI;                # Generic interface to a large number of databases
#~ use DBD::mysql;         # DBI driver for MySQL
#~ use DBD::SQLite;        # Self-contained RDBMS in a DBI Driver
use DBIx::RunSQL;       # Run SQL to create a database schema
use DBIx::Connector;    # Fast, safe DBI connection and transaction management
use DBIx::Connector::Driver::SQLite;    # SQLite-specific connection interface

use Data::Lock qw( dlock );     # Declare locked scalars

# use for debug only
#~ use Devel::Comments '###';      # debug only                             #~
#~ use Devel::Comments '#####', ({ -file => 'tr-debug.log' });              #~



#============================================================================#

# Pseudo-globals

# Error messages
dlock( my $err  = Test::Ranger->new(  # this only locks the reference
    _unpaired       => [ 'Unpaired arguments passed; named args required:'  ],
    _no_sql_file    => [ 'No SQL file passed:'                              ],
    _bad_sql_file   => [ 'Bad SQL file ($A[0]) passed:'                     ],
    _no_db_name     => [ 'No DB passed; must pass a file if not remembered.'],
    
    
) ); ## $err

# Database connection flags
dlock( my $DB_flags = {
    RaiseError          => 1,
    AutoCommit          => 1,
#~     AutoInactiveDestroy => 1,    # defaults to true in DBIx::Connector
#~     AutoInactiveDestroy => '1',  # raises warning if set explicitly
    
} );

#----------------------------------------------------------------------------#

#=========# OBJECT METHOD
#
#   $db     = $db->create( 
#               -db_name    => 'tr',        # (file)name of sqlite database
#               -sql_file   => 'setup.sql', # setup file contains SQL syntax
#               -verbose    => 1,           # print each SQL statement as run
#           );
#       
# Purpose   : Create a 'tr' database if it does not exist.
# Parms     : $db           : TR::DB object
#             -db_name      : string    : fully qualified
#             -sql_file     : string    : fully qualified
#             -verbose      : bool      : NOT USEFUL HERE?
# Reads     : -sql_file
# Returns   : $db           : itself
# Invokes   : DBIx::RunSQL->create()
# Writes    : -db_name
# Throws    : fatal if no or bad file passed
# See also  : TR::paired()
# 
# ____
#   
sub create {
    my $db          = shift;
    my %args        = paired(@_);
    my $db_name     = $args{-db_name}
        or $err->crash ('_no_db_name');
    my $user        = $args{-db_user};      # not supported by SQLite
    my $pass        = $args{-db_pass};      # not supported by SQLite
    my $sql_file    = $args{-sql_file}
        or $err->crash('_no_sql_file');
    -f $sql_file
        or $err->crash( "Not a file: ($sql_file)" );
    my $verbose     = $args{-verbose};
    
    # Actually create the DB. This should not be done often. 
    my $dsn         = "DBI:SQLite:$db_name";
    my $dbh         = DBIx::RunSQL->create(     # returns a new DBI object
                dsn     => $dsn,
                sql     => $sql_file,
                verbose => $verbose,
    );
    
    # It is better to die() than to return() in failure.
    # TODO: This test does not work properly; see RT#70998
    crash("Couldn't create DB from $sql_file") unless $dbh;
    
    # Close the returned handle and make a "connector" to the DB.
    $dbh            = undef;
    my $flags       = {%$DB_flags};         # make an editable copy
    my $conn        = DBIx::Connector->new($dsn, $user, $pass, $flags);
    
    $db->{-db_name} = $db_name;
    $db->{-conn}    = $conn;
    return $db;
}; ## create

#=========# OBJECT METHOD
#
#   $obj->connect( '-parm' => $value, );     # short
#       
# Purpose   : Connect to an existing DB; remembered or by file name. 
# Parms     : ____
# Reads     : ____
# Returns   : $dbh      : DBI object        # database handle
# Invokes   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
#   
sub connect {
    my $db          = shift;
    my %args        = paired(@_);
    my $conn        = $db->{-conn};         # remembered connection
    my $db_name     = $args{-db_name}       # or by file name passed
                   || $db->{-db_name};      # ... or stored
    my $user        = $args{-db_user};      # not supported by SQLite
    my $pass        = $args{-db_pass};      # not supported by SQLite
    
    ( $conn or $db_name )                   # assert at least one is true
        or crash ('_no_db_passed');
    
    my $dsn         = "DBI:SQLite:$db_name";
    my $dbh         ;
    
    if ($conn) {
        $dbh        = $conn->dbh();         # ? delete ?
    }
    else
    {
        my $flags       = {%$DB_flags};     # make an editable copy
        $conn            = DBIx::Connector->new($dsn, $user, $pass, $flags);
        $conn->mode('fixup');               # reuse handle optimistically
        $db->{-db_name} = $db_name;
        $db->{-conn}    = $conn;
        $dbh        = $conn->dbh();         # ? delete ?
    };
    
    return $conn;                           # returns "connector"
}; ## connect

#=========# OBJECT METHOD
#
#    $db     = $db->insert_term_command(    # add to command history
#                '-text' => $text, 
#            );
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
sub insert_term_command {
    my $db          = shift;
    my $conn        = $db->connect();       # remembered connection
    my %args        = paired(@_);
    my $text        = $args{-text};
    
    my $table       = 'term_command';
    my $F_text      = 'c_text';             # column name of this field
    my $sql         = "INSERT INTO $table ($F_text) VALUES (?)";
    my $sth         ;
    
    $conn->run( sub{                        # $_ aliased to the dbh
                $sth = $_->prepare($sql);
                     $sth->execute($text);
            } )
            or crash( "Insert failed:", $sth->errstr, $sql );
    
    return $db;
}; ## insert_term_command

#=========# OBJECT METHOD
#
#   $db->select_term_command( '-parm' => $value, );     # short
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
sub select_term_command {
    my $db          = shift;
    my $conn        = $db->connect();       # remembered connection
    my %args        = paired(@_);
    
    my $table       = 'term_command';
    my $sql         ;
#~     my $row ???          # TODO
    my $text        ;
    
    my $sth         ;
    my $cmds        ;   # $cmds->[$row][$col]
    
    # What to do?
    if    ( 0 ) {
                            # TODO
    } 
    elsif ( 0 ) {
        
    } 
    else {              # no %args left: select all
        $sql        = qq{SELECT * FROM $table};
    };
    
    # Access the DB...
    $conn->run( sub{                        # $_ aliased to the dbh
                $sth = $_->prepare($sql);
                     $sth->execute($text);
            } )
            or crash( "Select failed:", $sth->errstr, $sql );
    
    # ... and wrap up the results.
    while ( my @row = $sth->fetchrow_array ) {
        push @$cmds, [ @row ];
    };
    
    return $cmds;
}; ## select_term_command



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

