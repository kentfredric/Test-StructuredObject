package Test::StructuredObject::TestSuite;
use Moose;
use namespace::autoclean;

use Test::More;
extends 'Test::StructuredObject::CodeStub';
has items => ( isa => 'ArrayRef', required => 1, is => 'rw' );
around BUILDARGS => sub {
  my ( $orig, $class ) = ( shift, shift );
  if ( ref $_[0] ) {
    return $class->$orig( items => \@_ );
  }
  return $class->$orig(@_);
};
sub name { 'unnamed toplevel testsuite' }

sub run {
  my $self = shift;
  plan tests => scalar grep { !$_->isa('Test::StructuredObject::NonTest') } @{ $self->items };
  for my $test ( @{ $self->items } ) {
    $test->run();
  }
}

sub linearize {
  my $self = shift;
  my @items;
  for my $test ( @{ $self->items } ) {
    if ( $test->isa('Test::StructuredObject::TestSuite') ) {
      push @items, Test::StructuredObject::NonTest->new(
        code => sub {
          note "Running Linearized Subtest " . $self->name . '/' . $test->name;
        }
      );
      push @items, @{ $test->linearize->items };
      push @items, Test::StructuredObject::NonTest->new(
        code => sub {
          note "Ending Linearized Subtest " . $self->name . '/' . $test->name;
        }
      );

      next;
    }
    push @items, $test;
  }
  return Test::StructuredObject::TestSuite->new( items => \@items );
}

sub to_s {
    my $self = shift;
  my $i = 0;
  return $self->_label(
    join( ',', map { $_->isa('Test::StructuredObject::NonTest') ? $_->to_s : ++$i . '=>' . $_->to_s } @{ shift->items } ) );
}

__PACKAGE__->meta->make_immutable;

1;

