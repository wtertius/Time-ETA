use strict;
use warnings;

use Time::ETA;
use Test::More;

my $true = 1;
my $false = '';

=begin comment $tests format

my $tests [
    {
        value => undef,
        pz => $false,    # what should _is_positive_integer_or_zero() return
        p => $false,     # what should _is_positive_integer() return
    },


=end comment

=cut

my $tests = [
    {
        value => undef,
        pz => $false,
        p => $false,
    },
    {
        value => 'mememe',
        pz => $false,
        p => $false,
    },
    {
        value => -3,
        pz => $false,
        p => $false,
    },
    {
        value => 0,
        pz => $true,
        p => $false,
    },
    {
        value => 1,
        pz => $true,
        p => $true,
    },
    {
        value => 1.2,
        pz => $false,
        p => $false,
    },
];

foreach my $test (@{$tests}) {

    my $value = defined $test->{value} ? $test->{value} : '';

    is(Time::ETA::_is_positive_integer_or_zero(undef, $test->{value}), $test->{pz}, "_is_positive_integer_or_zero($value)");
    is(Time::ETA::_is_positive_integer(undef, $test->{value}), $test->{p}, "_is_positive_integer($value)");

}

done_testing();
