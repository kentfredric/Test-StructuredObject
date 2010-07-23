package Test::StructuredObject::NonTest;

# $Id:$
use strict;
use warnings;
use Moose;
extends 'Test::StructuredObject::CodeStub';
use namespace::autoclean;

has code => ( isa => 'CodeRef', required => 1, is => 'rw' );

sub _label {
    my $self = shift;
    return __PACKAGE__ . '(' . shift . ')';
}
__PACKAGE__->meta->make_immutable;

1;

