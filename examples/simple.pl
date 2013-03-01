#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use v5.010;
use lib::abs '../lib';
use Time::ETA;

my $number = 10;

my $eta = Time::ETA->new(
    milestones => $number,
);

foreach (1 .. $number) {

    if ($eta->if_remaining_seconds_is_known()) {
        say "ETA: " . $eta->get_remaining_seconds();
    } else {
        say "ETA is unknown";
    }

    sleep 1;
    $eta->pass_milestone();
}

say "#END"
