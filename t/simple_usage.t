#!/usr/bin/perl

use strict;
use warnings;

use Time::ETA;
use Time::HiRes qw(usleep gettimeofday tv_interval);
use Test::More;

my $precision = 0.01;

my $tests = [
    {
        count => 6,
        sleep_time => 1000000,
    },
    {
        count => 5,
        sleep_time => 750000,
    },
];

foreach my $test (@{$tests}) {

    my $eta = Time::ETA->new(
        milestones => $test->{count},
    );
    my $start_time = [gettimeofday];

    foreach my $i (1..$test->{count}) {

        if ($i == 1) {
            ok(not($eta->if_remaining_seconds_is_known()), "At first iteration we can't calculate ETA");
        } else {

            my $percent = $eta->get_completed_percent();
            my $secs = $eta->get_remaining_seconds();

            my $number_of_tasks_left = 1 + $test->{count} - $i;
            my $current_time = [gettimeofday];
            my $estimated_time = $number_of_tasks_left * ( tv_interval ( $start_time, $current_time) / ($i - 1) );

            ok(abs($percent - ((100 * ($i - 1) / $test->{count})) ) < $precision, "At loop $i got correct percent $percent");
            ok(abs($secs - $estimated_time) < $precision, "At loop $i got correct remainig time $secs");

        }

        usleep $test->{sleep_time};
        $eta->pass_milestone();
    }

}

done_testing();
