package Test::StructuredObject::CodeStub;

# $Id:$
use strict;
use warnings;
use Moose;
use namespace::autoclean;

use Carp qw( carp );

sub _label {
    return __PACKAGE__ . '(' .  shift  . ')';
}

sub dcode {
  my $self = shift;
  require B::Deparse;
  my $c = B::Deparse->new( "-x10", "-p", "-l", );
  $c->ambient_pragmas( strict => 'all', 'warnings' => 'all' );
  return $c->coderef2text( $self->code );
}

sub run {
  my $i;
  my $self = shift;
  eval { $i = $self->code->() };
  if ($@) {
    carp($@);
  }
  return $i;
}

sub to_s {
  my $self = shift;
  return $self->_label( $self->dcode );
}
__PACKAGE__->meta->make_immutable;

1;

