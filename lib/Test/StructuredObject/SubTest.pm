package Test::StructuredObject::SubTest;

# $Id:$
use strict;
use warnings;
use Moose;
use Test::More;
extends 'Test::StructuredObject::TestSuite';
use namespace::autoclean;
  has name => ( isa => 'Str', required => 1, is => 'rw' );
  sub run {
    my $self = shift;
    subtest $self->name, sub {
      plan tests => scalar grep { !$_->isa('NonTest') } @{ $self->items };
      for my $test ( @{ $self->items } ) {
        $test->run();
      }
    };
  }
  sub _label {
      my $self = shift;
      my $string = shift;
      return __PACKAGE__ . '(' . $self->name . ' => (' . $string  . ') )';
  }

  __PACKAGE__->meta->make_immutable;
1;

