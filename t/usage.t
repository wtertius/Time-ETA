#!/usr/bin/perl

use strict;
use warnings;

use Carp;
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

        my $serialization_string = $eta->serialize();
        my $respawned_eta = Time::ETA->spawn($serialization_string);

        foreach my $name ("original", "respawned") {
            my $current_eta = $eta;

            if ($name eq "original") {
                $current_eta = $eta;
            } elsif ($name eq "respawned") {
                $current_eta = $respawned_eta;
            } else {
                croak "Internal error. Stopped";
            }

            if ($i == 1) {
                ok(not($current_eta->can_calculate_eta()), "In $name object at first iteration we can't calculate ETA");

                # but if we try to get ETA we will get error
                eval {
                    my $value = $current_eta->get_remaining_seconds();
                };

                like(
                    $@,
                    qr/There is not enough data to calculate estimated time of accomplishment/,
                    "In $name object at first iteration we die if we try to use get_completed_percent()"
                );

                # but we still know the percent of completion (it is zero)
                is($current_eta->get_completed_percent(), 0, "In $name object at first iteration we know the percent of completion");

                ok(
                    abs(tv_interval ( $start_time, [gettimeofday]) - $current_eta->get_elapsed_seconds()) < $precision,
                    "In $name object at first iteration elapsed seconds are very small"
                );

            } else {

                my $percent = $current_eta->get_completed_percent();
                my $secs = $current_eta->get_remaining_seconds();
                my $elapsed_seconds = $current_eta->get_elapsed_seconds();

                my $number_of_tasks_left = 1 + $test->{count} - $i;
                my $current_time = [gettimeofday];
                my $estimated_time = $number_of_tasks_left * ( tv_interval ( $start_time, $current_time) / ($i - 1) );

                ok(abs($percent - ((100 * ($i - 1) / $test->{count})) ) < $precision, "In $name object at loop $i got correct percent $percent");
                ok(abs($secs - $estimated_time) < $precision, "In $name object at loop $i got correct remainig time $secs");

                ok(abs(tv_interval ( $start_time, $current_time) - $elapsed_seconds) < $precision, "In $name object at loop $i got correct elapsed seconds $elapsed_seconds");
            }
        }

        usleep $test->{sleep_time};
        $eta->pass_milestone();
    }

    eval {
        $eta->pass_milestone();
    };

    like(
        $@,
        qr/You have already completed all milestones/,
        "pass_milestone() can't be run after all the work is done",
    );
}

done_testing();
