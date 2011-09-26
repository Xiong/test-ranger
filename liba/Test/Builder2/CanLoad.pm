package Test::Builder2::CanLoad;

require Test::Builder2::Mouse;
use Test::Builder2::Mouse::Role;
with 'Test::Builder2::CanTry';


=head1 NAME

Test::Builder2::CanLoad - load modules without effecting global variables

=head1 SYNOPSIS

    package My::Thing;

    use Test::Builder2::Mouse;
    with "Test::Builder2::CanLoad";

    My::Thing->load("Some::Module");

=head1 DESCRIPTION

Test::Builder2 must be careful to leave the global state of the test
alone.  This especially includes things like $@ and $!.
Unfortunately, a lot of things change them.  C<require> is one of
them.

This module provides C<load> as a safe replacement for C<require>
which does not affect global variables (except the obvious ones like
C<%INC>).

=head3 load

    $class->load($module);

This works like L<require> to load a module, except it will not affect
C<$!> and C<$@> and not trip a C<$SIG{__DIE__}> handler.  Use it
internally in your test module when you want to load a module.

It B<will> die on failure if the $module fails to load in which case
it B<will> set C<$@>.  If you want to trap the failure, see
L<Test::Builder2::CanTry>.

=cut

sub load {
    my $self   = shift;
    my $module = shift;

    my $ret = $self->try(sub {
        my $path = $module;
        $path =~ s{::}{/}g;
        $path .= ".pm";
        require $path;
    }, die_on_fail => 1);

    return $ret;
}

=head1 SEE ALSO

L<Test::Builder2::CanTry>

=cut

no Test::Builder2::Mouse;
no Test::Builder2::Mouse::Role;

1;
