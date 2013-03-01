#!/usr/bin/perl

=encoding UTF-8
=cut

=head1 DESCRIPTION

=cut

# common modules
use strict;
use warnings FATAL => 'all';
use 5.010;
use DDP;
use Carp;
use lib::abs qw(
    ../lib
);

use Time::HiRes qw(usleep);

use ETA;

# global vars

# subs

# main
sub main {

    my $number = 10;

    my $eta = ETA->new(
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

    say '#END';
}

main();
__END__
