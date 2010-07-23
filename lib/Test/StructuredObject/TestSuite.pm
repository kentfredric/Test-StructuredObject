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

sub _run_items {
  my $self = shift;
  plan tests => scalar grep { !$_->isa('Test::StructuredObject::NonTest') } @{ $self->items };
  for my $test ( @{ $self->items } ) {
    $test->run();
  }
}

sub run {
  my $self = shift;
  $self->_run_items;
}

sub _label {
  my $self = shift;
  return __PACKAGE__ . '(' . shift . ')';
}

sub _gen_note_sub {
      my ( $pfix, $self, $test ) = @_;
     my $name = $self->name;
     my $subname = $test->name;
     my $code;
     eval "
     package Test::StructuredObject::TestSuite::linearize_note_eval;
     use Test::More;
     \$code = sub{ note(q{ $pfix Linearized Subtest $name / $subname }) }; 1 " or die;
     return Test::StructuredObject::NonTest->new( code => $code );
}
sub linearize {
  my $self = shift;
  my @items;
  for my $test ( @{ $self->items } ) {
    if ( $test->isa('Test::StructuredObject::TestSuite') ) {
      push @items, _gen_note_sub( "Running", $self, $test );
      push @items, @{ $test->linearize->items };
      push @items, _gen_note_sub("Ending", $self, $test );

      next;
    }
    push @items, $test;
  }
  return Test::StructuredObject::TestSuite->new( items => \@items );
}

sub to_s {
  my $self = shift;
  my $i    = 0;
  return $self->_label(
    join( ',',
      map { ( $_->isa('Test::StructuredObject::NonTest') ? "\n#step\n" : "\n#test " . ++$i . "\n" ) . $_->to_s }
        @{ $self->items } )
  );
}

__PACKAGE__->meta->make_immutable;

1;

