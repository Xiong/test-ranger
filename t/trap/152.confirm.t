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

# The kinds of STDOUT and STDERR that might be emitted by confirm().
my $ok_regex        = qr/^ok/m;
my $nok_regex       = qr/^not ok/m;
my $failed_regex    = qr/^#\s* Failed/m;
my $empty_regex     = qr/\A\z/;

my @test_data       = (
    { 
        -base   => 'die foo',
        -given  => {        # givens for this ranger script
            -code       => sub{ die 'foo' },    # given for bear trap
            -leaveby    => 'die',               # want  for bear trap
            -die        => akin('foo'),         # want  for bear trap
        },
        -want   => {        # wants for this ranger script
            -pass       => 1,
        }
    },
    
    { 
        -base   => 'say foo',
        -given  => {        # givens for this ranger script
            -code       => sub{ say 'foo' },    # given for bear trap
            -leaveby    => 'return',            # want  for bear trap
            -stdout     => akin('foo'),         # want  for bear trap
        },
        -want   => {        # wants for this ranger script
            -pass       => 1,
        }
    },
    
    { 
        -base   => 'bad die foo',
        -given  => {        # givens for this ranger script
            -code       => sub{ die 'foo' },    # given for bear trap
            -leaveby    => 'return',            # want  for bear trap
            -return     => akin('foo'),         # want  for bear trap
        },
        -want   => {        # wants for this ranger script
            -pass       => 0,
        }
    },
    
    { 
        -base   => 'fail foo',
        -given  => {        # givens for this ranger script
            -code       => sub{ say 'foo' },    # given for bear trap
            -leaveby    => 'return',            # want  for bear trap
            -return     => akin('bar'),         # want  for bear trap
        },
        -want   => {        # wants for this ranger script
            -pass       => 0,
        }
    },
    
    { 
        -base   => 'leaveby tardis',
        -given  => {        # givens for this ranger script
            -code       => sub{ say 'foo' },    # given for bear trap
            -leaveby    => 'tardis',            # want  for bear trap
            -return     => akin('foo'),         # want  for bear trap
        },
        -want   => {        # wants for this ranger script
            -crash      => akin( 'leaveby' ),
        }
    },
    
); ## test_data
#~ $tc++;
#~ pass('Starting...');

#----------------------------------------------------------------------------#
# EXECUTE AND CHECK

for my $i (0..$#test_data) {
    my $lineref     = $test_data[$i];
    my %line        = %$lineref;
    
    my $base        = $unit . qq{<$i> } . $line{-base} . q{ };
    
    my %given       = %{ $line{-given} };
        my $code        = $given{-code} 
            or crash('Must supply -code to test.');
    
    my %want        = %{ $line{-want } };
        my $want_pass   = $want{-pass};
        my $want_crash  = $want{-crash};
    
    my $inner_rv    ;
    
    # EXECUTE-RANGER
    my $r_rv = grab{
        my $capture = capture {
                  
            # EXECUTE-BEAR
            my $rv = trap{                  # just like daddy
                my $rv = &$code();
                return $rv;
            };
            
        ##### $trap    
#~         diag('Dumping inner trap:');                                     #~
#~         $trap->diag_all;            # Dumps the $trap object, TAP safe   #~
            
            # CHECK-BEAR    
                                    # bear's givens and wants are ranger's givens
            $inner_rv = $trap->confirm( 
                -base       => 'inside ' . $base,
                %given, 
            );
            
        }; ## capture
        return $capture;
    }; ## grab
    
    # CHECK-RANGER
#~     ##### $capture   
    ##### $grab   
    ##### $inner_rv   
    
    $base   = $base . q{--- };
    
    $tc++;
    $diag   = $base . 'captured and trapped';
    pass($diag);
    
    if ($want_crash) {
        $tc++;
        $diag   = $base . 'crashed as wanted';
        $grab->did_die($diag) or exit 1;
        
        $tc++;
        $diag   = $base . 'crashed like';
        $grab->die_like( $want_crash, $diag ) or exit 1;
        
        next;       # no need for further testing of this $i (%line)
    };
    
    $tc++;
    $diag   = $base . 'did_return';
    $grab->did_return($diag) or exit 1;
    
    $tc++;
    $diag   = $base . 'pass or fail correctly';
    $got    = $inner_rv;    # confirm() returns true or false (passed or failed)
    $want   = $want_pass;
    is( $got, $want, $diag ) or exit 1;
    
    if ($want_pass) {
        $tc++;
        $diag   = $base . 'want-pass, stdout ok';
        $grab->stdout_like( $ok_regex, $diag ) or exit 1;
        
        $tc++;
        $diag   = $base . 'want-pass, stderr empty';
        $grab->stderr_like( $empty_regex, $diag ) or exit 1;
        
    }
    else {
        $tc++;
        $diag   = $base . 'want-fail, stdout not ok';
        $grab->stdout_like( $nok_regex, $diag ) or exit 1;
        
        $tc++;
        $diag   = $base . 'want-pass, stderr failed';
        $grab->stderr_like( $failed_regex, $diag ) or exit 1;
                
    };
    
#~     $tc++;
#~     $diag   = $base . 'quiet';
#~     $grab->quiet($diag) or exit 1;      # no STDOUT or STDERR
        
    note(q{-});
    ##### xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
};

$tc++;
pass('...Done.');

#----------------------------------------------------------------------------#
# TEARDOWN

END {
    done_testing($tc);                  # declare plan after testing
}

#============================================================================#
