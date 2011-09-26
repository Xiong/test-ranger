#!/run/bin/perl

use 5.010001;
use strict;
use warnings;

use Test::More;

use Devel::Comments '#####', ({ -file => 'tr-debug.log' }); # debug only #~

my $test_builder = Test::More->builder;
##### $test_builder

diag('before');
pass('should pass');
fail('should fail');
say        'something to STDOUT';
say STDERR 'something to STDERR';

#~ close *STDOUT;
#~ my $STDOUT;
#~ open *STDOUT, '>', \$STDOUT;
#~ 
#~ close *STDERR;
#~ my $STDERR;
#~ open *STDERR, '>', \$STDERR;

my $saved_out       = Test::More->builder->{Out_FH};
my $saved_err       = Test::More->builder->{Fail_FH};
my $saved_cnt       = Test::More->builder->{Curr_Test};

Test::More->builder->output         ('result.txt');
Test::More->builder->failure_output ('errors.txt');

##### $test_builder

diag('quiet');
pass('should pass');
fail('should fail');
say        'something to STDOUT';
say STDERR 'something to STDERR';

Test::More->builder->output         ($saved_out);
Test::More->builder->failure_output ($saved_err);

##### $test_builder

diag('after');
pass('should pass');
fail('should fail');
say        'something to STDOUT';
say STDERR 'something to STDERR';

done_testing();                  # don't declare plan after testing

#============================================================================#
__END__

=for Output: 

xiong@oz:~/projects/test-ranger$ t/shit/154.bogus.t
# before
ok 1 - should pass
not ok 2 - should fail
#   Failed test 'should fail'
#   at t/shit/154.bogus.t line 11.
something to STDOUT
something to STDERR
# after
ok 3 - should pass
not ok 4 - should fail
#   Failed test 'should fail'
#   at t/shit/154.bogus.t line 25.
1..4
# Looks like you failed 2 tests of 4.

=cut
