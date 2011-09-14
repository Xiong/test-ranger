use 5.010000;
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

my $got         ;
my $want    ;
my $unit        = 'create(): ';
my $diag        = $unit;
my $tc          = 0;

my $db_name     = $ENV{tr_test_db_name}     //= 'file/db/tr_test_01';
my $sql_file    = $ENV{tr_sql_file}         //= 'file/db/tr_db.sql';
my $user        ;   # not supported by SQLite
my $pass        ;   # not supported by SQLite
my $sql         ;

unlink $db_name;            # cleanup previous test DB file if any
$got            = -f $db_name;      # is a plain file
$want           = undef;            # want it to *not* exist
$diag           = "$unit test unlinks existing  $db_name";
is( $got, $want, $diag );
$tc++;

#----------------------------------------------------------------------------#
# EXECUTE

my @rv = trap{
    # SETUP
    my $msg         ;

    my $db          = Test::Ranger::DB->new();
    $msg = $db->create(
        -db_name    => $db_name,
        -sql_file   => $sql_file,
    );
    return $msg;
};

#----------------------------------------------------------------------------#
# CHECK

#~ $trap->diag_all;                    # Dumps the $trap object, TAP safe

$got        = $trap->leaveby;           # 'return', 'die', or 'exit'.
$want       = 'return'; 
$diag       = "$unit returned normally";
is($got, $want, $diag);
$tc++;

$diag       = "$unit returned something";
$trap->return_ok(
    0,
    $diag,
);
$tc++;

$want       = words(qw( created ));
$diag       = "$unit says it created something";
$trap->return_like(
    0,
    $want,
    $diag,
);
$tc++;

$got        = -f $db_name;      # is a plain file
$diag       = "$unit test found             $db_name";
ok( $got, $diag );
$tc++;

my $dsn     = "DBI:SQLite:$db_name";
my $dbh     = DBI->connect($dsn, $user, $pass);
$diag       = "$unit test connected to      $db_name";
ok( $dbh, $diag );
$tc++;

# New $trap.
$sql        = q{INSERT INTO term_command (c_text) VALUES ('ls')};
my $rv = trap{
    my $rv = $dbh->do($sql);
};

$got        = $trap->leaveby;           # 'return', 'die', or 'exit'.
$want       = 'return'; 
$diag       = "$unit test insert returned normally";
is($got, $want, $diag);
$tc++;

$got        = $rv;
$diag       = "$unit test insert returned true";
ok( $got, $diag );
$tc++;

$got        = $dbh->disconnect();
$diag       = "$unit test disconnected";
ok( $got, $diag );
$tc++;

#----------------------------------------------------------------------------#
# TEARDOWN

if ( $ENV{tr_preserve_test_db} ) {
    diag "$db_name preserved."
}
else {
    unlink $db_name;
    note "$db_name unlinked."
};

done_testing($tc);                  # declare plan after testing

#============================================================================#

sub words {                         # sloppy match these strings
    my @words   = @_;
    my $regex   = q{};
    
    for (@words) {
        $regex  = $regex . $_ . '.*';
    };
    
    return qr/$regex/is;
};


