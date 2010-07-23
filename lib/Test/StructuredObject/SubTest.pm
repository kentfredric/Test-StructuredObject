use strict;
use warnings;

package Test::StructuredObject::SubTest;

# ABSTRACT: A Nested group of tests.

use Moose;
use Test::More;
extends 'Test::StructuredObject::TestSuite';
use namespace::autoclean;

=attr name

A descriptive name for this batch of C<subtests>.

=cut

has name => ( isa => 'Str', required => 1, is => 'rw' );

=method run

Execute all the child items inside a L<< C<Test::More> C<subtest>|Test::More/subtest >>
named after L<<< C<< ->name >>|/name >>>

=cut

sub run {
  my $self = shift;
  my $result;
  subtest $self->name, sub {
    $result = $self->_run_items();
  };
  return $result;
}

## no critic (ProhibitUnusedPrivateSubroutines)

sub _label {
  my $self   = shift;
  my $string = shift;
  return __PACKAGE__ . '(' . $self->name . ' => (' . $string . ') )';
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

