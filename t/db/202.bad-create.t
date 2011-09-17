use 5.010001;
use strict;
use warnings;

use Test::More;
use Test::Trap qw( :default );

use Test::Ranger::DB;

#============================================================================#
# 
# This script tests for unpaired arguments passed to create().
# Was 'odd_args'.

#----------------------------------------------------------------------------#
# SETUP

my $unit        = '::DB::create(): ';
my $got         ;
my $want        ;
my $diag        = $unit;
my $tc          = 0;

my $db_name     = $ENV{tr_test_db_name}     //= 'file/db/tr_test_01';

#----------------------------------------------------------------------------#
# EXECUTE

trap{

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
note( qq{\n} .$trap->die );

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


