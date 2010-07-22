use strict;
use warnings;
package Test::StructuredObject;

# ABSTRACT: Use a structured execution-graph to create a test object which runs your tests smartly.

=head1 SYNOPSIS

    use Test::More;
    use Test::StructuredObject;

    my $testsuite = testsuite(
        test { use_ok('Foo'); },
        test { is( Foo->value, 7, 'Magic value' },
        step { note "This is a step!"; }
        subtest( 'This is a subtest' => (
            test { ok( 1, 'some inner test' ) },
            test { ok( 1, 'another inner test' ) },
        ))
    );

    $testsuite->run(); # Employs Test::More's very recent 'subtest' call internally to do subtesting.
    $testsuite->linearize->run(); # Flattens the subtests into a linear fashion instead, decorated with 'note''s  for older Test::More's
    print $testsuite->to_s; # Prints a simplistic (non-reversable) serialisation of the testsuite or diagnostic purposes.

=cut

=head1 DESCRIPTION

This technique has various perks:

=over 4

=item 1. No need to count tests manually

=item 2. Tests are still counted internally, so test harness can report tests that failed to run.

=item 3. Tests are collected in a sort of state-graph of sorts, almost AST like in nature, which permits various runtime permutations of the graph for different results.

=item 4. Every test { } closure is executed in an eval { }, making subsequent tests not fail if one dies.

=item 5. Internal storage of many simple sub-calls allows reasonably good Deparse introspection, so if need be, the entire execution tree can easily be rewritten to be completely Test::StructuredObject free.

=back

However, it has various downsides, which for most things appear reasonable to me:

=over 4

=item 1. Due to lots of closures, the only present variable transience is achieved via external lexical variables. A good solution to this I've found is just predeclare all your needed variables and pretend they're like CPU registers =).

=item 2. Also, due to closure techniques, code that relies on C<->import> to do lexical scope mangling may not work. That is pesky for various reasons, but on average its not a problem, as it is, existing Test files need that BEGIN{  use_ok } stuff to get around this issue anyway.

But basically, all you need to do is 'use' in your file scope in these cases, or use Fully Qualified sub names instead.

If neither of these solutions appeals to you, YOU DON'T HAVE TO USE THIS MODULE!.

=back

=cut

use Test::More;
use Test::StructuredObject::TestSuite;
use Test::StructuredObject::SubTest;
use Test::StructuredObject::Test;
use Test::StructuredObject::NonTest;

use Sub::Exporter -setup => {
 exports => [ qw( test step testsuite subtests ) ],
 groups => { default => [qw( test step testsuite subtests ) ] },

};

sub test(&) {
  my $code = shift;
  return Test::StructuredObject::Test->new( code => $code );
}

sub step(&) {
  my $code = shift;
  return Test::StructuredObject::NonTest->new( code => $code );
}

sub testsuite(@) {
  my $i = Test::StructuredObject::TestSuite->new( items => \@_ );
#  $i->run();
  return $i;
}

sub subtests($@) {
  my $name  = shift;
  my @items = @_;
  return Test::StructuredObject::SubTest->new( name => $name, items => \@items );
}



1;
