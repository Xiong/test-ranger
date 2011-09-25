#!/run/bin/perl

use 5.010001;
use strict;
use warnings;

use lib qw( lib ../lib ../../lib);       # while under development       #~
use lib qw( liba ../liba ../../liba);       # load alpha versions        #~

#~ use Test::More tests => 1;
use Test::More;

use Test::Trap qw( :default );  # standard import()

use Devel::Comments '#####', ({ -file => 'tr-debug.log' }); # debug only #~

#~ trap{
    
#~     note('note here');
#~     diag('quiet');
    pass('should pass');
#~     fail('should fail');
    say        'something to STDOUT';
    say STDERR 'something to STDERR';
    
#~ };

##### $trap

my $tc;

$tc++;
pass('Outside');

#----------------------------------------------------------------------------#
# TEARDOWN
END {
    done_testing($tc);                  # declare plan after testing
}

#============================================================================#
