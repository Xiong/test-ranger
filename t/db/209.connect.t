use 5.010001;
use strict;
use warnings;

use Test::More;
use Test::Trap qw( :default );

use Test::Ranger::DB;

use DBI;                # Generic interface to a large number of databases
#~ use DBD::mysql;         # DBI driver for MySQL
use DBD::SQLite;        # Self-contained RDBMS in a DBI Driver
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
# EXECUTE

my $rv = trap{
    
    my $conn = $db->connect( -db_name => $db_name );   
    
    return $conn;
};

#----------------------------------------------------------------------------#
# CHECK

$trap->diag_all;                    # Dumps the $trap object, TAP safe   #~

$diag       = "$unit returned normally";
$tc++;
$got        = $trap->did_return($diag) or exit 1;

$diag       = "$unit returned something";
$tc++;
$trap->return_ok(
    0,               # even if :scalar, return => []
    $diag,
) or exit 1;

my $conn     = $rv;

#~ $got        = [];       # clear out previous contents
#~ @$got       = map { $_->[1] } @{ $rv };
#~ $want       = \@text,
#~ $diag       = "$unit returned three inserted commands deeply";
#~ $tc++;
#~ is_deeply( $got, $want, $diag ) or exit 1;

#~ my $dsn     = "DBI:SQLite:$db_name";
#~ my $dbh     = DBI->connect($dsn, $user, $pass);
#~ $diag       = "$unit test connected to      $db_name";
#~ $tc++;
#~ ok( $dbh, $diag ) or exit 1;

# New $trap.
$rv = trap{
    my $cmds = $db->select_term_command();   # no args: select *    
    
    return $cmds;     # returns an AoA ref: $cmds->[$row][$col]
};

$got        = [];       # clear out previous contents
@$got       = map { $_->[1] } @{ $rv };
$want       = \@text,
$diag       = "$unit returned three inserted commands deeply";
$tc++;
is_deeply( $got, $want, $diag ) or exit 1;

#~ $got        = $trap->leaveby;           # 'return', 'die', or 'exit'.
#~ $want       = 'return'; 
#~ $diag       = "$unit test select returned normally";
#~ $tc++;
#~ is($got, $want, $diag) or exit 1;

#~ $got        = $rv;
#~ $diag       = "$unit test select returned true";
#~ $tc++;
#~ ok( $got, $diag ) or exit 1;

#~ $got        = $dbh->disconnect();
#~ $diag       = "$unit test disconnected";
#~ $tc++;
#~ ok( $got, $diag ) or exit 1;

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

sub words {                         # sloppy match these strings
    my @words   = @_;
    my $regex   = q{};
    
    for (@words) {
        $regex  = $regex . $_ . '.*';
    };
    
    return qr/$regex/is;
};


