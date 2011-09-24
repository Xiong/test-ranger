use 5.010001;
use strict;
use warnings;

use Test::More;
use Test::Trap qw( :default );

use Test::Ranger::Base          # Base class and procedural utilities
    qw( :all );
use Test::Ranger::Trap;         # Comprehensive airtight trap and test

#~ use Devel::Comments '###';                                  # debug only #~
#~ use Devel::Comments '#####', ({ -file => 'tr-debug.log' });              #~

#============================================================================#
# 
# Tests the analyzer TR::Trap:: confirm(). This is a self test. 
# This test is failing because confirm() is not yet written. 
# 
# Two testing "personalities" in this script: the bear and the ranger. 
# The bear takes some simple code and tests it. 
# The ranger watches the bear and tests the bear. 
# Users of Test::Ranger will be using the bear. 
# 
#----------------------------------------------------------------------------#
# SETUP

my $unit        = '::Trap::confirm(): ';
my $got         ;
my $want        ;
my $diag        = $unit;
my $tc          = 0;        # the usual test counter for this script
my $one         = 1;       
my $zero        = 0;       

my @test_data       = (
    { 
        -base   => 'die foo',
        -given  => {        # givens for this ranger script
            -code       => sub{ die 'foo' },    # given for bear trap
            -leaveby    => 'die',               # want  for bear trap
            -die        => akin('foo'),         # want  for bear trap
        },
        -want   => {        # wants for this ranger script
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
    
    # EXECUTE-RANGER
    trap{        
        # SETUP-BEAR
        my $bear        = Test::Ranger::Trap->new();
        
        # EXECUTE-BEAR
        $bear->trap{        # should be this way, when...
            my $rv = &$code();
            return $rv;
        };
        
        # CHECK-BEAR    
        my $saved_trap      = $trap;                    # do-jiggery for now
        $bear->{-test_ranger}{-trap} = $saved_trap;     # more do-jiggery
        $saved_trap->diag_all;          # Dumps the $trap object, TAP safe   #~
        
        $bear->confirm( %given );
        
    }; ## trap
    
    # CHECK-RANGER
    $trap->diag_all;                # Dumps the $trap object, TAP safe   #~
    
    $tc++;
    $diag   = $base . 'did_return';
    $trap->did_return($diag) or exit 1;
    
    $tc++;
    $diag   = $base . 'pass';
    $got    = $trap->return(0);
    if ($pass) {
        ok(  $got, $diag ) or exit 1;
    } 
    else {
        ok( !$got, $diag ) or exit 1;       # !ok (ok if $got is false)
    };
    
    $tc++;
    $diag   = $base . 'quiet';
    $trap->quiet($diag) or exit 1;      # no STDOUT or STDERR
        
    note(q{-});
};

#----------------------------------------------------------------------------#
# TEARDOWN

END {
    done_testing($tc);                  # declare plan after testing
}

#============================================================================#
