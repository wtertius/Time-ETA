use strict;
use warnings;

use Time::ETA;
use Test::More;
use Time::HiRes qw(gettimeofday);

my $true = 1;
my $false = '';

my $precision = 0.1;

ok(1, "Loaded ok");

# Serialization api version 1
{

    my ($seconds, $microseconds) = gettimeofday;

    my $seconds_in_the_past = $seconds - 4;

    my $string = "---
_milestones: 10
_passed_milestones: 4
_start:
  - $seconds_in_the_past
  - $microseconds
_version: 1
";

    my $eta;
    eval {
        $eta = Time::ETA->spawn($string);
    };

    like(
        $@,
        qr/Can't spawn object\. Version .* can work only with serialized data version 2\./,
        "spawn() does not support serialization api version 1.",
    );

}

# Serialization api version 2
#
# The difference from version 1:
#
#  * when the process is finished the field "_end" appear
#
{

    my ($seconds, $microseconds) = gettimeofday;

    my $seconds_in_the_past = $seconds - 4;

    my $string = "---
_milestones: 10
_passed_milestones: 4
_start:
  - $seconds_in_the_past
  - $microseconds
_version: 2
";


    my $eta = Time::ETA->spawn($string);

    my $percent = $eta->get_completed_percent();
    my $secs = $eta->get_remaining_seconds();

    is($percent, 40, "Got expected percent from respawned object");
    cmp_ok(abs($secs-6), "<", $precision, "Got expected remaining seconds from respawned object");

}

done_testing();
