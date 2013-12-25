package Time::ETA::MockTime;

# ABSTRACT: make it possible to test time

=head1 DESCRIPTION

This is an internal thing that is used only in testing Perl module Time::ETA.

=cut

use warnings;
use strict;
use Exporter qw(import);
use Time::HiRes qw();
use Carp;

our @EXPORT_OK = qw(
    sleep
    usleep
    gettimeofday
);
our @EXPORT = @EXPORT_OK;

our @mocked_time = Time::HiRes::gettimeofday();
my $microseconds_in_second = 1_000_000;

=head1 sleep

=cut

sub sleep {
    my ($seconds) = @_;

    croak "Incorrect seconds" if $seconds !~ /^[0-9]+$/;
    $mocked_time[0] += $seconds;
}

=head1 usleep

=cut

sub usleep ($) {
    my ($microseconds) = @_;

    croak "Incorrect microseconds" if $microseconds !~ /^[0-9]+$/;

    $mocked_time[1] += $microseconds;
    my $ms = $mocked_time[1] % $microseconds_in_second;
    my $remain = $mocked_time[1] - $ms;

    $mocked_time[0] += ($remain / $microseconds_in_second);
    $mocked_time[1] = $ms;
}

=head1 gettimeofday

=cut


sub gettimeofday () {
    if (@mocked_time) {
        return wantarray ? @mocked_time : "$mocked_time[0].$mocked_time[1]";
    }
}

1;
