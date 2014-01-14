#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use Test::More;
use Time::ETA;
use Time::ETA::MockTime;

sub main {
    my $eta = Time::ETA->new(
        milestones => 2,
    );

    ok(not($eta->is_paused), 'At first the object it not paused');
    eval {
        $eta->resume();
    };
    like($@, qr/The object isn't paused\. Can't resume\. Stopped/, "Can't resume not paused");

    $eta->pause();
    ok($eta->is_paused, 'Paused');

    eval {
        $eta->pause();
    };
    like($@, qr/The object is already paused\. Can't pause paused\. Stopped/, "Can't pause paused");

    done_testing();
}

main();
