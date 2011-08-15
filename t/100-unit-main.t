use Test::More;
use Test::Trap qw( :default );  # trap{} and $trap exported by default

use Test::Ranger::Shell;    # module under test

#~ use Devel::Comments;        # Debug with executable smart comments to logs

#----------------------------------------------------------------------------#

my @test_list   = (
    {
        -name       => 'no-arguments',              # interactive by default
        -argv       => [],                          # no arguments
        -leaveby    => 'return',                    # normal return
        -return     => '_main_loop',                # enter main loop
        -stdout     => q{},                         # no STDOUT
        -stderr     => q{},                         # no STDERR
    },
    
    {
        -name       => '-1',                        # scripted mode
        -argv       => [qw( -1 ) ],                 # no arguments
        -leaveby    => 'return',                    # normal return
        -return     => '_one_shot',                 # do one shot
        -stdout     => q{},                         # no STDOUT
        -stderr     => q{},                         # no STDERR
    },
    
    {
        -name       => 'cp foo baz',                # interactive
        -argv       => [qw( cp foo baz ) ],         # arguments
        -leaveby    => 'return',                    # normal return
        -return     => '_one_shot',                 # do one shot
        -stdout     => q{},                         # no STDOUT
        -stderr     => q{},                         # no STDERR
    },
    

);

#----------------------------------------------------------------------------#

our $Debug          ;           # global hashref; debug and testing

my $test_counter    ;

@test_list  = expand(@test_list);   # insert defaults and propagate stickies

for (@test_list) {
    test($_);
};
done_testing($test_counter);
### @test_list
exit(0);

#----------------------------------------------------------------------------#

sub expand {
    return @_;
};

sub test {
    my $t           = shift;
    my $got         ;
    my $want        ;
    my $name        ;
    
    # Set up test conditions
    @ARGV               = @{ $t->{-argv} };
    $Debug->{-unit}     = 1;
    
    # Execute code under test
    my $rv  = trap{
        Test::Ranger::Shell::main();
    };
    
    # Check results
    $name       = join q{|}, $t->{-name}, 'leaveby';
    $got        = $trap->leaveby;           # 'return', 'die', or 'exit'
    $want       = $t->{-leaveby};
    $test_counter++;
    is  ( $got, $want, $name );             # ok if $got eq $want
    
    $name       = join q{|}, $t->{-name}, 'return';
    $got        = $rv;                      # normal return value
    $want       = $t->{-return};
    $test_counter++;
    is  ( $got, $want, $name );             # ok if $got eq $want
    
    $name       = join q{|}, $t->{-name}, 'stdout';
    $got        = $trap->stdout;            # STDOUT in one string
    $want       = $t->{-stdout};
    $test_counter++;
    is  ( $got, $want, $name );             # ok if $got eq $want
    
    $name       = join q{|}, $t->{-name}, 'stderr';
    $got        = $trap->stderr;            # STDERR in one string 
    $want       = $t->{-stderr};
    $test_counter++;
    is  ( $got, $want, $name );             # ok if $got eq $want
    
    
};

__END__
