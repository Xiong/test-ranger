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
my $tc          = 0;        # the usual test counter we'll pass
my $script_tc   = 0;        # private test counter for this script only
my $one         = 1;       
my $zero        = 0;       

my @test_data       = (
    { 
        -base   => 'die foo',
        -given  => {
            -code       => sub{ die 'foo' },
            -leaveby    => 'die',
            -die        => akin('foo'),
        },
        -want   => {
            -pass       => 1
        }
    },
    
); ## test_data

#----------------------------------------------------------------------------#
# EXECUTE AND CHECK

for my $i (0..$#test_data) {
    my $lineref     = $test_data[$i];
    my %line        = %$lineref;
    
    my $base        = $unit . $line{-base} . qq{<$i>};
    
    my %given       = %{ $line{-given} };
        my $code        = $given{-code} 
            or crash('Must supply -code to test.');
    
    my %want        = %{ $line{-want } };
        my $pass        = $want{-pass};
    
    # EXECUTE-BEAR
    my $rv = trap{        
        my $rv = &$code();
        return $rv;
    };
        
    # CHECK-BEAR    
    my $saved_trap      = $trap;
    $saved_trap->diag_all;          # Dumps the $trap object, TAP safe   #~
    
    # EXECUTE-RANGER
    trap{        
        confirm( $saved_trap, %given );
    };
    
    $trap->diag_all;                # Dumps the $trap object, TAP safe   #~
    
    $script_tc++;
    $diag   = $base . 'did_return';
    $trap->did_return($diag) or exit 1;
    
    $diag   = $base . 'pass';
    $got    = $trap->return(0);
    if ($pass) {
        ok(  $got, $diag ) or exit 1;
    } 
    else {
        ok( !$got, $diag ) or exit 1;       # !ok (ok if $got is false)
    };
    
    $script_tc++;
    $diag   = $base . 'quiet';
    $got    = join q{}, $trap->stdout, $trap->stderr;
    $want   = q{};
    is( $got, $want, $diag ) or exit 1;
        
    $script_tc++;
    note(q{-});
};

#----------------------------------------------------------------------------#
# TEARDOWN

END {
    done_testing($script_tc);                  # declare plan after testing
}

#============================================================================#
