#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use Test::More;

BEGIN {
    if (!eval q{ use Test::Differences; 1 }) {
        *eq_or_diff = \&is_deeply;
    }
}

use Capture::Tiny qw(capture_merged);
use Time::ETA::MockTime;

my $true = 1;
my $false = '';

sub do_work {
    sleep 1;
}

sub sample_from_pod {

    # sample start
    use Time::ETA;

    my $eta = Time::ETA->new(
        milestones => 12,
    );

    foreach (1..12) {
        do_work();
        $eta->pass_milestone();
        print "Will work " . $eta->get_remaining_seconds() . " seconds more\n";
    }
    # sample end

    return $false;
}

sub check_sample_from_pod {

    no warnings 'redefine';
    *Time::ETA::gettimeofday = \&Time::ETA::MockTime::gettimeofday;

    my $output = capture_merged {
        sample_from_pod();
    };

    my $expected_output = "Will work 11 seconds more
Will work 10 seconds more
Will work 9 seconds more
Will work 8 seconds more
Will work 7 seconds more
Will work 6 seconds more
Will work 5 seconds more
Will work 4 seconds more
Will work 3 seconds more
Will work 2 seconds more
Will work 1 seconds more
Will work 0 seconds more
";

    eq_or_diff(
        $output,
        $expected_output,
        'Sample from POD works as expected',
    );
}

sub main {
    check_sample_from_pod();

    done_testing();
}

main();
__END__
