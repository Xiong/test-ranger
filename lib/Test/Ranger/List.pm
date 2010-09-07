package Test::Ranger::List;

use strict;
use warnings;
use Carp;

use version 0.77; our $VERSION = qv('0.0.1');

## use

#============================================================================#

######## CLASS METHOD ########
#
#   my $obj = Test::Ranger::List->new();
#
#       Returns a hashref blessed into class of calling package
#
#       see also: init();
#
sub new {
    my $class   = $_[0];
    my $self    = {};
    
    bless ($self => $class);
    $self->init(@_);            # init all remaining args
    
    return $self;
}; ## new

######## OBJECT METHOD ########
#
#   $obj->init( $arg );
#
#       Initializes $obj with a preconstructed data structure.
#       $obj is a conventional hash-based object.
#       See docs for specification.
#
sub init {
    my $self    = $_[0];
    my $aref    = $_[1];
    
    # assign list to hash
    $self->{-list}      = $aref;
    
    return $self;
}; ## init


#############################
######## END MODULE #########
1;
__END__

=head1 NAME

Test::Ranger::List - Helper module for Test::Ranger. 

=head1 VERSION

This document describes Test::Ranger::List version 0.0.1

TODO: THIS IS A DUMMY, NONFUNCTIONAL RELEASE.

=head1 SYNOPSIS

    use Test::Ranger;

=head1 DESCRIPTION

This class represents a list of Test::Ranger objects. Please see the main 
L<Test::Ranger> documentation for details. 

=head1 AUTHOR

Xiong Changnian  C<< <xiong@cpan.org> >>

=head1 LICENSE

Copyright (C) 2010 Xiong Changnian C<< <xiong@cpan.org> >>

This library and its contents are released under Artistic License 2.0:

L<http://www.opensource.org/licenses/artistic-license-2.0.php>

=cut
