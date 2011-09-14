use 5.010000;
use strict;
use warnings;

use Test::More;
use Test::Trap qw( :default );

use Test::Ranger::DB;

#============================================================================#
# 
# This script tests the _crash() error handler for 'unpaired' to create().
# Was 'odd_args'.

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
        'foo',      # unpaired argument
    );

};

#----------------------------------------------------------------------------#
# CHECK

#~ $trap->diag_all;                    # Dumps the $trap object, TAP safe

$trap->did_die("$unit dies correctly when fed unpaired argument");
$tc++;

$trap->die_like(
    words(qw( unpaired arg create )),
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

sub words {             # construct a regex that matches these strings
    my @words   = @_;
    my $regex   = q{};
    
    for (@words) {
        $regex  = $regex . $_ . '.*';
    };
    
    return qr/$regex/is;
};


