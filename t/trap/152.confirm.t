use 5.010001;
use strict;
use warnings;

use lib qw( liba ../liba ../../liba);       # load alpha versions        #~
use Test::More;
use Test::Builder2::Tester;                 # Testing a Test:: module
use Test::Trap qw( grab $grab :default );   # nonstandard import()

use Test::Ranger::Base          # Base class and procedural utilities
    qw( :all );
use Test::Ranger::Trap;         # Comprehensive airtight trap and test
                                # ... also imports $trap and trap{}

use Devel::Comments '#####', ({ -file => 'tr-debug.log' }); # debug only #~

#~ die '---------die after use-ing';
#============================================================================#
# 
# Tests the analyzer TR::Trap:: confirm(). This is a self test. 
# This test will fail if extended because should-fails will leak out. 
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
    
    { 
        -base   => 'say foo',
        -given  => {        # givens for this ranger script
            -code       => sub{ say 'foo' },    # given for bear trap
            -leaveby    => 'return',            # want  for bear trap
            -return     => akin('foo'),         # want  for bear trap
        },
        -want   => {        # wants for this ranger script
            -pass       => 1
        }
    },
    
); ## test_data
$tc++;
pass('Starting...');

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
    my $capture = capture {
              
        # EXECUTE-BEAR
        my $rv = trap{                  # just like daddy
            my $rv = &$code();
            return $rv;
        };
        
#~     ##### $trap    
        
#~         diag('Dumping inner trap:');                                     #~
#~         $trap->diag_all;            # Dumps the $trap object, TAP safe   #~
        
        # CHECK-BEAR    
                                # bear's givens and wants are ranger's givens
        my $rv_c = $trap->confirm( 
            -base       => 'inside ' . $base,
            %given, 
        );
        return $rv_c;
        
    }; ## capture
#~     $tc     += $r_rv;       #keep track of number of inner tests run
    
    # CHECK-RANGER
    ##### $capture   
#~     diag('Dumping outer trap:');                                         #~
#~     $grab->diag_all;        # Dumps the $grab ($trap) object, TAP safe   #~
    
    $tc++;
    $diag   = $base . 'captured';
    pass($diag);
    
#~     $tc++;
#~     $diag   = $base . 'did_return';
#~     $grab->did_return($diag) or exit 1;
    
#~     $tc++;
#~     $diag   = $base . 'return value';
#~     $got    = $r_rv;        # returns number of tests run (passed or failed)
#~     $want   = 1;            # may want to relax this
#~     is( $got, $want, $diag );
    
#~     $got    = $grab->return(0);
#~     if ($pass) {
#~         ok(  $got, $diag ) or exit 1;
#~     } 
#~     else {
#~         ok( !$got, $diag ) or exit 1;       # !ok (ok if $got is false)
#~     };
    
#~     $tc++;
#~     $diag   = $base . 'quiet';
#~     $grab->quiet($diag) or exit 1;      # no STDOUT or STDERR
        
    note(q{-});
};

#----------------------------------------------------------------------------#
# TEARDOWN

END {
    done_testing($tc);                  # declare plan after testing
}

#============================================================================#
