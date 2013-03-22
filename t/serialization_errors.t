use strict;
use warnings;

use Test::More;
use Time::ETA;

sub test_can_cpawn {
    my ($string) = @_;

    my $result = Time::ETA->can_spawn($string);

    ok(not($result), "can_spawn() return false");

    return '';
}

# no string
{
    eval {
        my $eta = Time::ETA->spawn();
    };

    like(
        $@,
        qr/Can't spawn Time::ETA object\. No serialized data specified\./,
        "spawn() does not work without serialized string",
    );

    test_can_cpawn();
}

# incorrect string
{

    my $string = "incorrect";

    eval {
        my $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn Time::ETA object\. Got error from YAML parser:/,
        "spawn() does not work incorrect serialized string",
    );

    test_can_cpawn($string);
}

# incorrect string
{

    my $string = "--- []
";

    eval {
        my $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn Time::ETA object\. Got incorrect serialized data/,
        "spawn() does not work incorrect serialized string",
    );

    test_can_cpawn($string);
}

# no version
{

    my $string = "---
_milestones: 10
_passed_milestones: 4
";

    eval {
        my $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn Time::ETA object\. Serialized data does not contain version/,
        "spawn() does not work without serialized api version",
    );

    test_can_cpawn($string);
}

# incorrect version
{

    my $string = "---
_milestones: 10
_passed_milestones: 4
_version: 1044
";

    eval {
        my $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn Time::ETA object\. Version $Time::ETA::VERSION can work only with serialized data version/,
        "spawn() works only with some serialized api versions",
    );

    test_can_cpawn($string);
}

# incorrect milestones
{

    my $string = "---
_milestones: -3
_passed_milestones: 4
_version: $Time::ETA::SERIALIZATION_API_VERSION
";

    eval {
        my $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn Time::ETA object\. Serialized data contains incorrect number of milestones/,
        "spawn() works only with correct number of milestones",
    );

    test_can_cpawn($string);
}

# incorrect passed milestones
{

    my $string = "---
_milestones: 186
_passed_milestones: asdf
_version: $Time::ETA::SERIALIZATION_API_VERSION
";

    eval {
        my $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn Time::ETA object\. Serialized data contains incorrect number of passed milestones/,
        "spawn() works only with correct number of passed milestones",
    );

    test_can_cpawn($string);
}

# incorrect passed milestones
{

    my $string = "---
_milestones: 186
_passed_milestones: asdf
_version: $Time::ETA::SERIALIZATION_API_VERSION
";

    eval {
        my $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn Time::ETA object\. Serialized data contains incorrect number of passed milestones/,
        "spawn() works only with correct number of passed milestones",
    );

    test_can_cpawn($string);
}

# no start time info
{

    my $string = "---
_milestones: 186
_passed_milestones: 10
_version: $Time::ETA::SERIALIZATION_API_VERSION
";

    my $eta;
    eval {
        $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn Time::ETA object\. Serialized data contains incorrect data for start time/,
        "spawn() works only with correct start time info",
    );

    test_can_cpawn($string);
}

# incorrect seconds in start time info
{

    my $string = "---
_milestones: 186
_passed_milestones: 10
_version: $Time::ETA::SERIALIZATION_API_VERSION
_start:
  - mememe
  - 631816
";

    my $eta;
    eval {
        $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn Time::ETA object\. Serialized data contains incorrect seconds in start time/,
        "spawn() works only with correct start time info",
    );

    test_can_cpawn($string);
}

# incorrect microseconds in start time info
{

    my $string = "---
_milestones: 186
_passed_milestones: 10
_version: $Time::ETA::SERIALIZATION_API_VERSION
_start:
  - 1362672010
  - -934
";

    my $eta;
    eval {
        $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn Time::ETA object\. Serialized data contains incorrect microseconds in start time/,
        "spawn() works only with correct start time info",
    );

    test_can_cpawn($string);
}

done_testing();
