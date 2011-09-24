use 5.010001;
use strict;
use warnings;

use Test::More;
use Test::Trap qw( grab $grab :default );  # nonstandard import()

use Test::Ranger::Base          # Base class and procedural utilities
    qw( :all );
use Test::Ranger::Trap          # Comprehensive airtight trap and test
#~     ;                           # ... also imports $trap and trap{}
    qw( snap $snap);               # ... imports $snap and snap{}

use Devel::Comments '#####', ({ -file => 'tr-debug.log' }); # debug only #~



##### $snap

#~ $trap->diag_all;      # Dumps the $trap object, TAP safe   #~

#~ $grab->diag_all;        # Dumps the $grab ($trap) object, TAP safe   #~


#----------------------------------------------------------------------------#
# TEARDOWN
pass('dummy');
END {
    done_testing();                  # don't declare plan after testing
}

#============================================================================#
