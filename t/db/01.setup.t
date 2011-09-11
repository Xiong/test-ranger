use 5.010000;
use strict;
use warnings;

use Test::More;
use Test::Trap qw( :default );

use Test::Ranger::DB;

#============================================================================#
# 
# This script tests the setup and teardown of all following tests.

#----------------------------------------------------------------------------#
# SETUP

my $got         ;
my $expected    ;
my $unit        = 'create(): ';
my $diag        = $unit;
my $tc          = 0;

#----------------------------------------------------------------------------#
# EXECUTE

trap{
    # SETUP
    my $db_name     = 'tr-test';
    my $msg         ;

    my $db          = Test::Ranger::DB->new();
    $msg = $db->create(
        -db_name    => $db_name,
        
    );
    return $msg;
};

#----------------------------------------------------------------------------#
# CHECK

$got        = $trap->leaveby;           # 'return', 'die', or 'exit'.
$expected   = 'return'; 
$diag       = "$unit returned normally";
is($got, $expected, $diag);
$tc++;

$diag       = "$unit returned something";
$trap->return_ok(
    1,
    $diag,
);
$tc++;

$expected   = words(qw( created ));
$diag       = "$unit created something";
$trap->return_like(
    1,
    $expected,
    $diag,
);
$tc++;


#----------------------------------------------------------------------------#
# TEARDOWN

#~ $msg = $db->delete(
#~     -db_name    => $db_name,
#~     -warn_me    => undef,
#~ );
#~ 


done_testing($tc);                      # declare plan after testing

sub words {             # construct a regex that matches these strings
    my @words   = @_;
    my $regex   = q{};
    
    for (@words) {
        $regex  = $regex . $_ . '.*';
    };
    
    return qr/$regex/is;
};


