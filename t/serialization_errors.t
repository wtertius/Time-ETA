use strict;
use warnings;

use Test::More;
use Time::ETA;

# no string
{
    eval {
        my $eta = Time::ETA->spawn();
    };

    like(
        $@,
        qr/Can't spawn object\. No serialized data specified\./,
        "spawn() does not work without serialized string",
    );
}

# incorrect string
{

    my $string = "incorrect";

    eval {
        my $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn object\. Got error from YAML parser:/,
        "spawn() does not work incorrect serialized string",
    );

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
        qr/Can't spawn object\. Got incorrect serialized data/,
        "spawn() does not work incorrect serialized string",
    );

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
        qr/Can't spawn object\. Serialized data does not contain version/,
        "spawn() does not work without serialized api version",
    );

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
        qr/Can't spawn object\. Version $Time::ETA::VERSION can work only with serialized data version/,
        "spawn() works only with some serialized api versions",
    );

}

# incorrect milestones
{

    my $string = "---
_milestones: -3
_passed_milestones: 4
_version: 1
";

    eval {
        my $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn object\. Serialized data contains incorrect number of milestones/,
        "spawn() works only with correct number of milestones",
    );

}

# incorrect passed milestones
{

    my $string = "---
_milestones: 186
_passed_milestones: asdf
_version: 1
";

    eval {
        my $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn object\. Serialized data contains incorrect number of passed milestones/,
        "spawn() works only with correct number of passed milestones",
    );

}

# incorrect passed milestones
{

    my $string = "---
_milestones: 186
_passed_milestones: asdf
_version: 1
";

    eval {
        my $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn object\. Serialized data contains incorrect number of passed milestones/,
        "spawn() works only with correct number of passed milestones",
    );

}

# no start time info
{

    my $string = "---
_milestones: 186
_passed_milestones: 10
_version: 1
";

    my $eta;
    eval {
        $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn object\. Serialized data contains incorrect data for start time/,
        "spawn() works only with correct start time info",
    );
}

# incorrect seconds in start time info
{

    my $string = "---
_milestones: 186
_passed_milestones: 10
_version: 1
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
        qr/Can't spawn object\. Serialized data contains incorrect seconds in start time/,
        "spawn() works only with correct start time info",
    );
}

# incorrect microseconds in start time info
{

    my $string = "---
_milestones: 186
_passed_milestones: 10
_version: 1
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
        qr/Can't spawn object\. Serialized data contains incorrect microseconds in start time/,
        "spawn() works only with correct start time info",
    );
}

done_testing();
