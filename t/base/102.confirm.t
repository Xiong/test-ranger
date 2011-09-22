use 5.010001;
use strict;
use warnings;

use Test::More;
use Test::Trap qw( :default );

use Test::Ranger qw(:all);      # Testing tool base class and utilities
use Test::Ranger::DB;

#~ use Devel::Comments '###';                                  # debug only #~
#~ use Devel::Comments '#####', ({ -file => 'tr-debug.log' });              #~

#============================================================================#
# 
# Tests the regex generator TR::confirm(). This is a Test::Ranger itself test. 

#----------------------------------------------------------------------------#
# SETUP

my $unit        = 'TR::confirm(): ';
my $got         ;
my $want        ;
my $diag        = $unit;
my $tc          = 0;
my $one         = 1;       
my $zero        = 0;       

# pass              : bool      : should match?
# "test" results    : string    : simulated results
# akin() args       : scalar or aryref
my @test_data   = (
    # pass? # "test" results        # akin() args
    [ 1,    'a',            'a'             ],
    [ 1,    undef,          undef           ],
    [ 1,    undef,          '*'             ],
    [ 0,   '*',             ''              ],
    [ 1,   '',              '*'             ],
    [ 0,   'a',             ''              ],
    [ 0,   'abc',           ''              ],
    [ 0,   7,               ''              ],
    [ 1,   'abcde',         '*'             ],
    [ 1,   42,              '*'             ],
    [ 1,   qq{\n},          '*'             ],
    [ 0,   qq{\n},          ''              ],
    [ 0,   1,               q{ }            ],
    [ 0,   1,               q{   }          ],
    [ 0,   1,               qq{\n}          ],
    [ 0,   1,               qq{\t}          ],
    [ 0,   1,               0               ],
    [ 0,   1,               []              ],
    [ 1,   1,               \$one           ],
    [ 0,   0,               \$one           ],
    [ 0,   0E0,             \$one           ],
    [ 0,   1,               \$zero          ],
    [ 1,   0,               \$zero          ],
    [ 0,   0E0,             \$zero          ],
    [ 1,   'error',         'error'         ],
    [ 0,   'pass',          'error'         ],
    [ 1,   'pass error',    'error'         ],
    [ 1,   'abc',           qw( a  c )      ],
    [ 1,   'abc',           [ qw( a  c ) ]  ],
#~     [ 1,   ],
#~     [ 1,   ],
#~     [ 1,   ],
#~     [ 1,   ],
#~     [ 1,   ],
#~     [ 1,   ],

); ## test_data

#----------------------------------------------------------------------------#
# EXECUTE AND CHECK

for my $i (0..$#test_data) {
    my $lineref     = $test_data[$i];
    my @line        = @$lineref;
    my @line_copy   = map { 
                        if    ( not defined $_ )        { q{} }
                        elsif ( $_ eq qq{\n} )          { q{\n} }
                        elsif ( $_ eq qq{\t} )          { q{\t} }
                        elsif ( ref $_ eq 'SCALAR' )    { $$_ }
                        elsif ( ref $_ eq 'ARRAY' )     { join q{.}, @$_ }
                        else                            { $_ } 
                    } @line;
##### @line_copy
    my $want        = shift @line;
    my $given       = shift @line;
    
    my @args       = @line;
##### @args
    
    my $base   =  $unit . qq{<$i> } 
                . q{|}
                . ( join q{|}, @line_copy ) 
                . q{|}
                ;
    
    # EXECUTE
    my $rv = trap{        
        my $pass = $want =~ akin(@args);
        return $pass;
    };
        
    # CHECK
    
#~     $trap->diag_all;                # Dumps the $trap object, TAP safe   #~
    
    $tc++;
    $diag   = $base . 'did_return';
    $trap->did_return($diag) or exit 1;
    
    $tc++;
    $diag   = $base . 'quiet';
    $got    = join q{}, $trap->stdout, $trap->stderr;
    $want   = q{};
    is( $got, $want, $diag ) or exit 1;
        
    $tc++;
    $diag   = $base . 'pass';
    $got    = $trap->return(0);
    is( $got, $want, $diag ) or exit 1;
    
    note(q{-});
};

#----------------------------------------------------------------------------#
# TEARDOWN

END {
    done_testing($tc);                  # declare plan after testing
}

#============================================================================#
