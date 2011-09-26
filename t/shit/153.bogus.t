#!/run/bin/perl

use 5.010001;
use strict;
use warnings;

use Test::More;

#~ use Test::Trap qw( grab $grab :default );  # nonstandard import()
use Test::Trap qw( :default );  # standard import()

use Test::Builder::Tester;
use Test::Builder::Tester::Color;

#~     use Test::Ranger::Base          # Base class and procedural utilities
#~         qw( :all );
#~     use Test::Ranger::Trap          # Comprehensive airtight trap and test
#~         ;                           # ... also imports $trap and trap{}
#~         qw( snap $snap);               # ... imports $snap and snap{}

use Devel::Comments '#####', ({ -file => 'tr-debug.log' }); # debug only #~

trap{
    
    diag('quiet');
    test_out("ok " . line_num(+1) . " - should pass");
    pass('should pass');
    test_out("not ok 1 - should fail");
    test_fail(+1);
    fail('should fail');
    test_test("fail works");
    say        'something to STDOUT';
    say STDERR 'something to STDERR';
    
};

pass('Done');

##### $trap

#~ $trap->diag_all;      # Dumps the $trap object, TAP safe   #~

#~ $grab->diag_all;        # Dumps the $grab ($trap) object, TAP safe   #~


#----------------------------------------------------------------------------#
# TEARDOWN
pass('dummy');
END {
    done_testing();                  # don't declare plan after testing
}

#============================================================================#
