use 5.010000;
use strict;
use warnings;

use Test::More;
use Test::Trap qw( :default );

use Test::Ranger::DB;

#============================================================================#
# 
# This script tests the _crash() error handler for 'odd_args' to create().

#----------------------------------------------------------------------------#
# SETUP
my $got         ;
my $expected    ;
my $unit        = '_crash(): ';
my $diag        = $unit;
my $tc          = 0;

#----------------------------------------------------------------------------#
# EXECUTE

trap{

    my $db_name     = 'tr-test';

    my $db          = Test::Ranger::DB->new();
    my $msg = $db->create(
        -db_name    => $db_name,
        'foo',      # odd argument
    );

};

#----------------------------------------------------------------------------#
# CHECK

#~ $trap->diag_all;                    # Dumps the $trap object, TAP safe

$trap->did_die("$unit dies correctly when fed odd number of arguments");
$tc++;

$trap->die_like(
    qr/odd/,
    "$unit emits expected error message",
);
$tc++;

#~ $got        = $trap->leaveby;           # 'return', 'die', or 'exit'.
#~ $expected   = 'die'; 
#~ $diag       = "$unit dies when fed odd number of arguments";
#~ is($got, $expected, $diag);
#~ $tc++;
#~ 

#----------------------------------------------------------------------------#
# TEARDOWN



done_testing($tc);                      # declare plan after testing


