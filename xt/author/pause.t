#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use Test::More;

BEGIN {
    if (!eval q{ use Test::Differences; 1 }) {
        *eq_or_diff = \&is_deeply;
    }
}

use Carp;
use Capture::Tiny qw(capture_merged);

use Time::ETA;
use Time::ETA::MockTime;

my $true = 1;
my $false = '';

sub do_work {
    sleep 1;
}

sub run_check {
    my (%params) = @_;

    my $method = $params{method};

    my $eta = Time::ETA->new(
        milestones => 12,
    );

    foreach (1..12) {
        do_work();
        if ($params{with_pause}) {
            $eta->pause();
            sleep(2);
            $eta->resume();
        }
        do_work();
        $eta->pass_milestone();

        print $eta->$method . "\n";
    }

}

sub check {
    my (%params) = @_;

    no warnings 'redefine';
    *Time::ETA::gettimeofday = \&Time::ETA::MockTime::gettimeofday;

    my $output = capture_merged {
        run_check(
            with_pause => $params{with_pause},
            method => $params{method},
        );
    };

    my $expected_output;

    if ($params{method} eq 'get_elapsed_seconds') {
        foreach (my $i = 2; $i<=24; $i+=2) {
            $expected_output .= "$i\n";
        }
    } elsif ($params{method} eq 'get_remaining_seconds') {
        foreach (my $i = 22; $i>=0; $i-=2) {
            $expected_output .= "$i\n";
        }
    } else {
        $params{method} = '' if not defined $params{method};
        croak "Unknown method: $params{method}";
    }

    eq_or_diff(
        $output,
        $expected_output,
        "Method $params{method} "
            . ($params{with_pause} ? "with pause" : "without pause")
            . " works as expected"
            ,
    );
}

sub main {

    check(
        with_pause => $false,
        method => 'get_elapsed_seconds',
    );

    check(
        with_pause => $false,
        method => 'get_remaining_seconds',
    );

    check(
        with_pause => $true,
        method => 'get_elapsed_seconds',
    );

    check(
        with_pause => $true,
        method => 'get_remaining_seconds',
    );

    done_testing();
}

main();
__END__
