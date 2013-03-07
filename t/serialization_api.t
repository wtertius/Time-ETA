use strict;
use warnings;

use Time::ETA;
use Test::More;
use Time::HiRes qw(gettimeofday);

my $precision = 0.1;

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

    my $eta = Time::ETA->spawn($string);

    my $percent = $eta->get_completed_percent();
    my $secs = $eta->get_remaining_seconds();

    is($percent, 40, "Got expected percent from respawned object");
    cmp_ok(abs($secs-6), "<", $precision, "Got expected remaining seconds from respawned object");

}

done_testing();
