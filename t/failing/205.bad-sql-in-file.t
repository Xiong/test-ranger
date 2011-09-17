use 5.010001;
use strict;
use warnings;

use Test::More;
use Test::Trap qw( :default );

use Test::Ranger::DB;

#~ use Devel::Comments '#####', ({ -file => 'tr-debug.log' });

#============================================================================#
# 
# This script tests bad SQL in the file to create().
# The current script is passed, which surely is not good SQL.
# This test will fail until either:
#   (a) DBIx::RunSQL is fixed to fatal out or return false; or
#   (b) create() does something to check schema of the DB.

#----------------------------------------------------------------------------#
# SETUP
my $got         ;
my $expected    ;
my $unit        = '::DB::create(): ';
my $diag        = $unit;
my $tc          = 0;

my $db_name     = $ENV{tr_test_db_name}     //= 'file/db/tr_test_01';
my $sql_file    = $0;      # current script will not be good SQL

#----------------------------------------------------------------------------#
# EXECUTE

trap{

    my $db          = Test::Ranger::DB->new();
    my $msg = $db->create(
        -db_name    => $db_name,
        -sql_file   => $sql_file,
    );

};

#----------------------------------------------------------------------------#
# CHECK

#~ $trap->diag_all;                    # Dumps the $trap object, TAP safe

$tc++;
$trap->did_die("$unit dies correctly when given crap .sql file (\$0)")
    or exit 1;

$tc++;
$trap->die_like(
    words(qw( create DB ) ),
    "$unit emits expected error message",
) or exit 1;
#~ note( qq{\n Died with: } . $trap->die );
note( qq{\n sql_file: } . $sql_file );

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

