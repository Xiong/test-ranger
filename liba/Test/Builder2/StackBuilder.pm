package Test::Builder2::StackBuilder;

use 5.008001;
use Test::Builder2::Mouse;
use Test::Builder2::Mouse::Exporter;
use Test::Builder2::Types;

use Carp qw(confess);


=head1 NAME

Test::Builder2::StackBuilder - A stack builder

=head1 SYNOPSIS

    # TODO

    use Test::Builder2::StackBuilder;
    buildstack items => 'Int';

    # is the same as having said:

    has items => (
        is => 'rw',
        isa => 'ArrayRef[Int]',
        default => sub{[]},
    );
    sub items_push { ... }
    sub items_pop  { ... }
    sub items_count{ ... }
        
=head1 DESCRIPTION

Exports a keyword buildstack to build up an Attribute array and methods consistanly.

=head1 EXPORTED FUNCTIONS

=head2 buildstack

  buildstack $name; # stack is just an ArrayRef
  buildstack $name => $subtype; # ArrayRef[$subtype]

=cut

Test::Builder2::Mouse::Exporter->setup_import_methods(
    as_is => [ 'buildstack' ],
);

sub buildstack ($;$) {
    my $meta = caller->meta;
    my ( $name, $subtype ) = @_;
    $meta->add_attribute(
        $name => is      => 'rw',
                 isa     => (defined $subtype) ? qq{ArrayRef[$subtype]} : q{ArrayRef} ,
                 default => sub{[]},
    );

    $meta->add_method(
        $name.'_push' => sub{ push @{ shift->$name }, @_; }
    ) unless $meta->has_method($name.'_push');

    $meta->add_method(
        $name.'_pop'  => sub{ pop @{ shift->$name } }
    ) unless $meta->has_method($name.'_pop');
    
    $meta->add_method(
        $name.'_count'=> sub{ scalar( @{ shift->$name } ) }
    ) unless $meta->has_method($name.'_count');
    
}


no Test::Builder2::Mouse;
1;
