use strict;
use warnings;

use Test::More;
use Time::ETA;
use Time::HiRes qw(
    gettimeofday
);

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

my $gettimeofday_tests = [
    {
        value => [gettimeofday()],
        name => undef,
        correct => $false,  # no name
    },
    {
        value => [gettimeofday()],
        name => 'start time',
        correct => $true,
    },
];

foreach my $test (@{$gettimeofday_tests}) {

    my $result;
    eval {
        $result = Time::ETA::_check_gettimeofday(
            undef,
            name => $test->{name},
            value => $test->{value},
        );
    };

    if ($test->{correct}) {
        is($@, "", "_check_gettimeofday() run successfully");
    } else {
        like(
            $@,
            qr/Expected to get 'name'/,
            "_check_gettimeofday() fail on error",
        );
    }

}

done_testing();
