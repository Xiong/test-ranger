{
    package Acme::Teddy;
    sub one{ 1 };
}
use strict;
use warnings;

use Acme::Teddy;
use Test::Ranger;

# Minimum
my $test    = Test::Ranger->new(
    {
        -coderef    => \&Acme::Teddy::one,
    },
    
); ## end new

$test->test();

