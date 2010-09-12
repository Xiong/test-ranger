{
    package Acme::Teddy;
    sub one{ 1 };
}
use strict;
use warnings;

use Acme::Teddy;
use Test::Ranger;
use Test::More;

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
        -given      => 
            -args       => [ {} ],
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

test($list);
done($list);

#----------------------------------------------------------------------------#

sub execute {
    my $self            = shift;
    
    my $coderef     = $self->{-coderef};
    my @args        = @{ $self->{-given}{-args} };
    my $got         ;
    
    # The real execution.
    $got            = &$coderef( @args );
    
    $self->{-return}{-value}{-got}  = $got;
    
    return 1;
};

# $self                         # a single declaration
#       -scan                   # set of scans              # $scan_key
#           -return             # return from execution     # $out_key
#               -value          # value returned            # $type_key
#                   -probe      # kind of probe
#                   -want       # expectation
#                   -got        # actual result
#               -ref            # ref( value )              # $type_key
#                   -probe      # type of probe
#                   -want       # expectation
#                   -got        # actual result
# 
sub check {
    my $self            = shift;
    my $scan            = $self->{-scan};           # $scan: tree branch
    my $fullname        = $self->{-fullname};
    my $counter         = $self->{-plan_counter};
    
    foreach my $scan_key ( keys %$scan ) {
        foreach my $out_key ( keys %{ $scan->{$scan_key} } ) {
            foreach my $type_key ( keys %{ $scan->{$scan_key}{$out_key} } ) {
                my $probe       = $scan->{$scan_key}{$out_key}{$ype_key}{-probe};
                my $got         = $scan->{$scan_key}{$out_key}{$ype_key}{-got};
                my $want        = $scan->{$scan_key}{$out_key}{$ype_key}{-want};
                given ($probe) {
                    when ('is')     { is(   $got, $want, $name) } 
                    when ('like')   { like( $got, $want, $name) } 
                };
                $counter++;
            };
        };
    };
    
    
    return 1;
};

sub test {
    my $self            = shift;
    
    # Expand, execute, check
    foreach my $single ( $self->{-list} ) {
        $single->{-plan_counter}    = 0;
        $single->{-fullname}        = join q'-',
                                        $self->{-basename},
                                        $single->{-name};
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
