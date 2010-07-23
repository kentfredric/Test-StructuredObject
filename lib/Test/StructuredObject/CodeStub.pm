use strict;
use warnings;

package Test::StructuredObject::CodeStub;

# ABSTRACT: The base class of all executable tests.

use Moose;
use namespace::autoclean;

use Carp qw( carp );

=head1 DESCRIPTION

This class is basically a C<functor>. At least, all derived packages are. This top level class has
no implicit code storage part, and this module really B<should> be reimplemented as a role. But laziness.

This top level provides few basic utilities to inheriting packages, largely L<< C<dcode>|/dcode >> , L<< C<run>|/run >> and L<< C<to_s>|/to_s >>.

=cut

sub _label {
  my $self = shift;
  return __PACKAGE__ . '(' . shift . ')';
}

=method C<dcode>

Return the source-code of this objects C<coderef> using L< B::Deparse|B::Deparse >.
Will not work on the base class as it needs C<< ->code >> to work.

=cut

sub dcode {
  my $self = shift;
  require B::Deparse;
  my $c = B::Deparse->new(qw( -x10  -p  -l ));
  $c->ambient_pragmas( strict => 'all', 'warnings' => 'all' );
  return $c->coderef2text( $self->code );
}

=method C<run>

Execute this objects C<coderef> inside an C< eval { } > block.

In the event of a failure emanating from the C<eval>'d code, that error is passed to L<carp|Carp/carp>

Return value of the C<coderef> is passed to the caller.

Will not work on the base class as it needs C<< ->code >> to work.

=cut

sub run {
  ## no critic ( ProhibitPunctuationVars )
  my $i;
  my $self = shift;
  my $evalresult = eval { $i = $self->code->(); 1 };
  if ( not $evalresult ) {
    carp($@);
  }
  return $i;
}

=method C<to_s>

Pretty-print this object in a serialisation-like format showing the source for the C<coderef>.

Will not work on the base class as it needs L<<< C<< ->dcode >>|/dcode >>> and thus C<< ->code >> to work.

=cut

sub to_s {
  my $self = shift;
  return $self->_label( $self->dcode );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

