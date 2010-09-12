{
    package Acme::Teddy;
    sub one{ 1 };
}
use 5.010000;
use strict;
use warnings;

use Acme::Teddy;
use Test::Ranger;
use Test::More;

use Devel::Comments '######';
#~ use Devel::Comments '#####';
#~ use Devel::Comments '####';
#~ use Devel::Comments '###';
#~ use Devel::Comments;

#----------------------------------------------------------------------------#

# Unit test of new().
my $unit        = sub {
    return Test::Ranger->new(@_);
};

my $list        = {
    -basename       => q'new',
    -list           => [],
    -plan_counter   => 0,
    -coderef        => $unit,
};

$list->{-list}  = [
    {
        -name       => q'empty-hashref',
        -given      => {
            -args       => [ {} ],
        },
        -scan       => {
            -return     => {
                -ref        => {
                    -probe      => q'is',
                    -want       => q'Test::Ranger',
                },
            },
        },
    },
    
]; ## -list

### Before:
### $list

test($list);
done($list);

### After:
### $list

#----------------------------------------------------------------------------#

sub expand {
    my $single      = shift;
    my $list        = shift;
    
    if ( !defined $single->{-coderef} ) {
        $single->{-coderef}     = $list->{-coderef};
    };
    
    $single->{-plan_counter}    = 0;
    $single->{-fullname}        = join q'-',
                                    $list->{-basename},
                                    $single->{-name};
    
    return 1;
};

sub execute {
    my $self            = shift;
    ##### $self
    my $coderef     = $self->{-coderef};
    ##### $coderef
    my @args        = @{ $self->{-given}{-args} };
    my $got         ;
    
    # The real execution.
    $got            = &$coderef( @args );
    
    # Store results.
    $self->{-scan}{-return}{-value}{-got}  = $got;
    
    if ( defined $self->{-scan}{-return}{-ref} ) {
        $self->{-scan}{-return}{-ref}{-got}   = ref $got;
    };
    
    return 1;
};

# $self                         # a single declaration
#       -scan                   # set of scans
#           -return             # return from execution     # $key_1
#               -value          # value returned            # $key_2
#                   -probe      # kind of probe
#                   -want       # expectation
#                   -got        # actual result
#               -ref            # ref( value )              # $key_2
#                   -probe      # type of probe
#                   -want       # expectation
#                   -got        # actual result
# 
sub check {
    my $self            = shift;
    my $scan            = $self->{-scan};           # $scan: tree branch
    my $count           = $self->{-plan_counter};
    #### $scan
    for my $key_1 ( keys %$scan ) {
        for my $key_2 ( keys %{ $scan->{$key_1} } ) {
            #### $key_1
            #### $key_2
            my $check       = $scan->{$key_1}{$key_2};
            my $probe       = $check->{-probe};
            my $got         = $check->{-got};
            my $want        = $check->{-want};
            my $name        = $check->{-name};
            ###### $name
            given ($probe) {
                when ('is')     { is(   $got, $want, $name); $count++; } 
                when ('like')   { like( $got, $want, $name); $count++; } 
            };
        };
    };
    
    $self->{-plan_counter}  = $count;
    return 1;
};

sub test {
    my $self            = shift;
    
    # Expand, execute, check
    foreach my $single ( @{ $self->{-list} } ) {
        expand($single, $self);
        execute($single);
        check($single);
        
        $self->{-plan_counter}      += $single->{-plan_counter};
        
    };
    
    return 1;
};

sub done {
    my $self            = shift;
    done_testing($self->{-plan_counter});
    return 1;
};


__END__
