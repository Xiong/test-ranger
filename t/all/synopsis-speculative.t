use strict;
use warnings;

use Acme::Teddy;
use Test::Ranger;

# Object-oriented usage
my $ranger    = Test::Ranger->new({
    -coderef    => \&Acme::Teddy::_egg,
    -name   => 'teddy-egg',
});
    
$ranger->cub({
    -parent     => $std
    -name       => '4*7',
    -given      => [ 4, 7 ],
    -return     => {
        -is         => 42,
    },
    -stdout     => {
        -like       => [ qw(hello world) ],
        -matches    => 2,
        -lines      => 1,
    },
});
    
my $ranger  = Test::Ranger->new({
    -name       => 'teddy-egg',
    -code       => \&Acme::Teddy::_egg,
});
    
    
    
    
    {
        -name       => '9*9',
        -given      => [ 9, 9 ],
        -return     => {
            -is         => 81,
        },
    },
    
    {
        -name       => 'string',
        -given      => [ 'monkey' ],
        -warn       => {
            -like       => 'dummy',
        },
    },
    
]); ## end new

$list->test();

