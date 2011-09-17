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
use Devel::Comments '#####', ({ -file => 'tr-debug.log' });              #~

#============================================================================#
# 
# This script selects all from command history table term_command.

#----------------------------------------------------------------------------#
# SETUP

my $unit        = '::DB::select_term_command(): ';
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

unlink $db_name;            # cleanup previous test DB file if any
$got            = -f $db_name;      # is a plain file
$want           = undef;            # want it to *not* exist
$diag           = "$unit test unlinks existing  $db_name";
is( $got, $want, $diag );
$tc++;

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
    
    my $cmds = $db->select_term_command();   # no args: select *    
    
    return $cmds;     # returns an AoA ref: $cmds->{$row}{$col}
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
    0,               # even if :scalar, return => []
    $diag,
);
$tc++;

@$got       = map { $_->[1] } @$rv;
$want       = \@text,
$diag       = "$unit returned three inserted commands deeply";
is_deeply( $got, $want, $diag );
$tc++;

#~ my $dsn     = "DBI:SQLite:$db_name";
#~ my $dbh     = DBI->connect($dsn, $user, $pass);
#~ $diag       = "$unit test connected to      $db_name";
#~ ok( $dbh, $diag );
#~ $tc++;

#~ # New $trap.
#~ $sql        = q{SELECT * FROM term_command};
#~ $rv = trap{
#~     my $sth = $dbh->prepare($sql);
#~     $rv = $sth->execute
#~         or die $sth->errstr;
#~     $rv = [];                           # clear good return from execute
#~     while ( my @row = $sth->fetchrow_array ) {
#~         push @$rv, [ @row ];
#~     };
#~     return $rv;
#~ };

#~ $got        = $trap->leaveby;           # 'return', 'die', or 'exit'.
#~ $want       = 'return'; 
#~ $diag       = "$unit test select returned normally";
#~ is($got, $want, $diag);
#~ $tc++;

#~ $got        = $rv;
#~ $diag       = "$unit test select returned true";
#~ ok( $got, $diag );
#~ $tc++;

#~ $got        = $dbh->disconnect();
#~ $diag       = "$unit test disconnected";
#~ ok( $got, $diag );
#~ $tc++;

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


