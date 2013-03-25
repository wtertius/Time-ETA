use Test::More;
use Time::ETA;

my $tests = [
    {
        input => 0,
        expected_result => "0:00:00",
    },
    {
        input => 1,
        expected_result => "0:00:01",
    },
    {
        input => 11,
        expected_result => "0:00:11",
    },
    {
        input => 61,
        expected_result => "0:01:01",
    },
    {
        input => 3600,
        expected_result => "1:00:00",
    },
    {
        input => 3601,
        expected_result => "1:00:01",
    },
    {
        input => 86402,
        expected_result => "24:00:02",
    },
    {
        input => 14.87,
        expected_result => "0:00:14",
    },
];

foreach (@{$tests}) {
    is(
        Time::ETA::_get_time_from_seconds(undef, $_->{input}),
        $_->{expected_result},
        "_get_time_from_seconds() worked ok for value '$_{input}'",
    );
}

# test failure
my $result;
eval {
    $result = Time::ETA::_get_time_from_seconds(undef, "string");
};

like(
    $@,
    qr/isn't numeric/,
    "_get_time_from_seconds() does not work with non number parameter",
);

done_testing();
