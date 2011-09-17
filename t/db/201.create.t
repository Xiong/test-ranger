use 5.010001;
use strict;
use warnings;

use Test::More;
use Test::Trap qw( :default );

use Test::Ranger::DB;

use DBI;                # Generic interface to a large number of databases
#~ use DBD::mysql;         # DBI driver for MySQL
use DBD::SQLite;        # Self-contained RDBMS in a DBI Driver

#~ use Devel::Comments '###';                                  # debug only #~

#============================================================================#
# 
# This script tests the setup and teardown of all following tests.

#----------------------------------------------------------------------------#
# SETUP

my $unit        = '::DB::create(): ';
my $got         ;
my $want        ;
my $diag        = $unit;
my $tc          = 0;

my $db_name     = $ENV{tr_test_db_name}     //= 'file/db/tr_test_01';
my $sql_file    = $ENV{tr_sql_file}         //= 'file/db/tr_db.sql';
#~ my $verbose     = $ENV{tr_test_verbose};
my $user        ;   # not supported by SQLite
my $pass        ;   # not supported by SQLite
my $sql         ;

unlink $db_name;            # cleanup previous test DB file if any
$got            = -f $db_name;      # is a plain file
$want           = undef;            # want it to *not* exist
$diag           = "$unit test unlinks existing  $db_name";
$tc++;
is( $got, $want, $diag ) or exit 1;

#----------------------------------------------------------------------------#
# EXECUTE

my @rv = trap{
    # SETUP
    my $msg         ;

    my $db          = Test::Ranger::DB->new();
    $msg = $db->create(
        -db_name    => $db_name,
        -sql_file   => $sql_file,
#~         -verbose    => $verbose,
    );
    return $msg;
};

#----------------------------------------------------------------------------#
# CHECK

#~ $trap->diag_all;                    # Dumps the $trap object, TAP safe

$got        = $trap->leaveby;           # 'return', 'die', or 'exit'.
$want       = 'return'; 
$diag       = "$unit returned normally";
$tc++;
is($got, $want, $diag) or exit 1;

$diag       = "$unit returned something";
$tc++;
$trap->return_ok(
    0,
    $diag,
) or exit 1;

$got        = -f $db_name;      # is a plain file
$diag       = "$unit test found             $db_name";
$tc++;
ok( $got, $diag ) or exit 1;

my $dsn     = "DBI:SQLite:$db_name";
my $dbh     = DBI->connect($dsn, $user, $pass);
$diag       = "$unit test connected to      $db_name";
$tc++;
ok( $dbh, $diag ) or exit 1;

# New $trap.
$sql        = q{INSERT INTO term_command (c_text) VALUES ('ls')};
my $rv = trap{
    my $rv = $dbh->do($sql);
};

$got        = $trap->leaveby;           # 'return', 'die', or 'exit'.
$want       = 'return'; 
$diag       = "$unit test insert returned normally";
$tc++;
is($got, $want, $diag) or exit 1;

$got        = $rv;
$diag       = "$unit test insert returned true";
$tc++;
ok( $got, $diag ) or exit 1;

$got        = $dbh->disconnect();
$diag       = "$unit test disconnected";
$tc++;
ok( $got, $diag ) or exit 1;

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


