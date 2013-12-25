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

my $true = 1;
my $false = '';

sub do_work {
    sleep 1;
}

sub fix {
    my ($content) = @_;

    $content =~ s/(\d+)\.00\d+/$1.00/g;

    return $content;
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
    my $output = capture_merged {
        sample_from_pod();
    };

    my $expected_output = "Will work 11.001887 seconds more
Will work 10.002564 seconds more
Will work 9.002363 seconds more
Will work 8.002022 seconds more
Will work 7.0017386 seconds more
Will work 6.001466 seconds more
Will work 5.00116571428572 seconds more
Will work 4.000922 seconds more
Will work 3.00067333333333 seconds more
Will work 2.0004268 seconds more
Will work 1.00016927272727 seconds more
Will work 0 seconds more
";

    $output = fix($output);
    $expected_output = fix($expected_output);

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
