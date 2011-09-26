use 5.010001;
use strict;
use warnings;

use Test::More;

use Test::Ranger::Base          # Base class and procedural utilities
    qw( :all );
use Test::Ranger::Trap;         # Comprehensive airtight trap and test

#~ use Devel::Comments '###';                                  # debug only #~
#~ use Devel::Comments '#####', ({ -file => 'tr-debug.log' });              #~

#============================================================================#
# 
# Tests the regex generator TR::akin(). This is a Test::Ranger itself test. 
# This is a paired test.

#----------------------------------------------------------------------------#
# SETUP

my $unit        = 'akin()-with-confirm() : ';
my $got         ;
my $want        ;
my $diag        = $unit;
my $tc          = 0;
my $one         = 1;
my $zero        = 0;

##### $QRTRUE
##### $QRFALSE

# pass              : bool      : should match?
# "test" results    : string    : simulated results
# akin() args       : scalar or aryref
my @test_data   = (
    # pass? # "test" results        # akin() args
    # $pass # $want         # @given
    [ 1,    'a',            'a'             ],
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
    [ 0,   0E0,             \$one           ],      # OK
    [ 0,   1,               \$zero          ],
    [ 1,   0,               \$zero          ],
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

#    [ 1,    undef,          undef           ],     # can't try to match undef
#    [ 1,    undef,          '*'             ],     # can't try to match undef
#    [ 0,   0E0,             \$zero          ],     # NOT OK
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
#~ ##### in test script: 
#~ ##### @line_copy
    
    my $pass        = shift @line;
    my $want        = shift @line;
    my @given       = @line;
#~ ##### @given
    
    my $base   =  $unit . qq{<$i> } 
                . q{|}
                . ( join q{|}, @line_copy ) 
                . q{|}
                ;
    
    # EXECUTE
    my $rv = trap{    
        my $akin    = akin(@given);  
#~         say STDERR $akin;                    # debug the test only       #~
        my $rv      = $want =~ /$akin/;
        return $rv;
    };
    
    # CHECK
##### in test script 
##### $rv        
##### $pass    
#~     $trap->diag_all;                # Dumps the $trap object, TAP safe   #~
    
    $tc++;
    $diag   = $base . 'confirm';
    my $want_here   = $pass ? $QRTRUE : $QRFALSE; 
    $trap->confirm(
        -base   => $base,
        -return => $want_here,          # match what we expect, simply
    );
        
    note(q{-});
}; ## for test_data

#----------------------------------------------------------------------------#
# TEARDOWN

END {
    done_testing($tc);                  # declare plan after testing
#~     done_testing();                  # declare no plan at all
}

#============================================================================#
