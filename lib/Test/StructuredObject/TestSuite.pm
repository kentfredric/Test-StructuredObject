use strict;
use warnings;

package Test::StructuredObject::TestSuite;

# ABSTRACT: A collection of tests in an order waiting to be executed.

use Moose;
use Carp qw( croak );
use namespace::autoclean;

use Test::More;
extends 'Test::StructuredObject::CodeStub';

=attr C<items>

An array of testable items.

=cut

has items => ( isa => 'ArrayRef', required => 1, is => 'rw' );
around BUILDARGS => sub {
  my ( $orig, $class ) = ( shift, shift );
  if ( ref $_[0] ) {
    return $class->$orig( items => \@_ );
  }
  return $class->$orig(@_);
};

=method name

Simply  returns the string to use inside C<linearize>'d C<TestSuite>s.

=cut
sub name { return 'unnamed toplevel testsuite' }

sub _run_items {
  my $self = shift;
  plan tests => scalar grep { !$_->isa('Test::StructuredObject::NonTest') } @{ $self->items };
  return [ map { $_->run() } @{ $self->items } ];
}

=method C<run>

execute each one of C<< $self->items >>

=cut

sub run {
  my $self = shift;
  return $self->_run_items;
}

sub _label {
  my $self = shift;
  return __PACKAGE__ . '(' . shift . ')';
}

sub _gen_note_sub {
  my ( $pfix, $self, $test ) = @_;
  my $name    = $self->name;
  my $subname = $test->name;
  my $code;

  ## no critic ( ProhibitStringyEval , ProhibitPunctuationVars )
  eval( 'package Test::StructuredObject::TestSuite::linearize_note_eval;'
      . 'use Test::More;'
      . "\$code = sub{ note(q{ $pfix Linearized Subtest $name / $subname }) }; 1 " )
    or croak($@);
  return Test::StructuredObject::NonTest->new( code => $code );
}

=method C<linearize>

Flatten all nested subsets to produce a C<TestSuite> containing only C<Test> and C<NonTest> entries.

This  is handy for backwards compatibility with older C<Test::More> instances.

=cut

sub linearize {
  my $self = shift;
  my @items;
  for my $test ( @{ $self->items } ) {
    if ( $test->isa('Test::StructuredObject::TestSuite') ) {
      push @items, _gen_note_sub( 'Running', $self, $test );
      push @items, @{ $test->linearize->items };
      push @items, _gen_note_sub( 'Ending',  $self, $test );

      next;
    }
    push @items, $test;
  }
  return Test::StructuredObject::TestSuite->new( items => \@items );
}

=method C<to_s>

pretty-print ( Serialisation-like ) a string representation of this object in a recursive way.

Handy for seeing the internal representation of the prepared test.

=cut

sub to_s {
  my $self = shift;
  my $i    = 0;
  return $self->_label(
    join q{,},
    map { ( $_->isa('Test::StructuredObject::NonTest') ? "\n#step\n" : "\n#test " . ++$i . "\n" ) . $_->to_s } @{ $self->items }
  );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

