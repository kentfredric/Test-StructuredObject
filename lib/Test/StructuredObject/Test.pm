use strict;
use warnings;

package Test::StructuredObject::Test;

# ABSTRACT: A L<< C<CodeStub>|Test::StructuredObject::CodeStub >> representing executable test code.

use Moose;
extends 'Test::StructuredObject::CodeStub';
use namespace::autoclean;

=attr code

The C<coderef> to execute during L<< C<run>|Test::StructuredObject::CodeStub/run >>

=cut

has code => ( isa => 'CodeRef', required => 1, is => 'rw' );

## no critic ( ProhibitUnusedPrivateSubroutines )

sub _label {
  my $self = shift;
  return __PACKAGE__ . '(' . shift . ')';
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

