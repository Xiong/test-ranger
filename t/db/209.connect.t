use 5.010001;
use strict;
use warnings;

use Test::More;

use Test::Ranger::Base          # Base class and procedural utilities
    qw( :all );
use Test::Ranger::Trap;         # Comprehensive airtight trap and test
use Test::Ranger::DB;           # Database interactions with SQLite

use DBI;                # Generic interface to a large number of databases
#~ use DBD::mysql;         # DBI driver for MySQL
#~ use DBD::SQLite;        # Self-contained RDBMS in a DBI Driver
use DBIx::Connector;    # Fast, safe DBI connection and transaction management

#~ use Devel::Comments '###';                                  # debug only #~
#~ use Devel::Comments '#####', ({ -file => 'tr-debug.log' });              #~

#============================================================================#
# 
# This script tests the ability to connect() to an existing DB.

#----------------------------------------------------------------------------#
# SETUP

my $unit        = '::DB::connect(): ';
my $got         ;
my $want        ;
my $base        = $unit;
my $diag        = $unit;
my $tc          = 0;

#~ my $db_name     = $ENV{tr_test_db_name}     //= 'file/db/tr_test_01';
my $db_name     = $ENV{tr_test_db_name}     //= ':memory';
my $sql_file    = $ENV{tr_sql_file}         //= 'file/db/tr_db.sql';
#~ my $verbose     = $ENV{tr_test_verbose};
my $user        ;   # not supported by SQLite
my $pass        ;   # not supported by SQLite
my $sql         ;
my $dsn         = "DBI:SQLite:$db_name";

unlink $db_name;            # cleanup previous test DB file if any
$got            = -f $db_name;      # is a plain file
$want           = undef;            # want it to *not* exist
$diag           = "$unit test unlinks existing  $db_name";
$tc++;
is( $got, $want, $diag ) or exit 1;

my $db          = Test::Ranger::DB->new();
$db->create(
    -db_name    => $db_name,
    -sql_file   => $sql_file,
#~     -verbose    => $verbose,
);

my @text        = (
                    'ls -l',
                    'cat food',
                    'echo ${USER}',
                );
for my $text (@text) {
    $db->insert_term_command(    # add to command history
            '-text' => $text, 
        );
};

#----------------------------------------------------------------------------#
# EXECUTE-connect()

my $rv = trap{    
    my $conn = $db->connect( -db_name => $db_name );   
};

#----------------------------------------------------------------------------#
# CHECK-connect()

#~ ##### $trap

$tc++;
$base       = "$unit - connect() ";
$trap->confirm(
    -base       => $base,
    -leaveby    => 'return',
);

#----------------------------------------------------------------------------#
# EXECUTE-select()

# New $trap.
$rv = trap{
    my $cmds = $db->select_term_command();   # no args: select *    
    
    return $cmds;     # returns an AoA ref: $cmds->[$row][$col]
};

#----------------------------------------------------------------------------#
# CHECK-select()

#~ ##### $trap

$tc++;
$base       = "$unit - select_term_command() ";
$trap->confirm(
    -base       => $base,
    -leaveby    => 'return',
);

$tc++;
$diag       = "$base returned three inserted commands deeply";
$got        = [];       # clear out previous contents
@$got       = map { $_->[1] } @{ $rv };
$want       = \@text,
is_deeply( $got, $want, $diag ) or exit 1;

#----------------------------------------------------------------------------#
# TEARDOWN

END {
    if ( $ENV{tr_preserve_test_db} ) {
        diag "$db_name preserved."
    }
    else {
        unlink $db_name;
        note "$db_name unlinked."
    };

    done_testing($tc);                  # declare plan after testing
}

#============================================================================#
