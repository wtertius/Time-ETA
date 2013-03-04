package Time::ETA;

# ABSTRACT: calculate estimated time of accomplishment

=head1 SYNOPSIS

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

=cut

use warnings;
use strict;

use Carp;

my $true = 1;
my $false = '';

=head2 new

B<Get:>

B<Return:>

=cut

sub new {
    my ($class, %params) = @_;
    my $self = {};
    bless $self, $class;

    croak "Expected to get parameter 'milestones'. Stopped" if not defined $params{milestones};
    croak "Parameter 'milestones' should be positive integer. Stopped" if not $self->_is_positive_integer($params{milestones});

    $self->{_milestones} = $params{milestones};
    $self->{_passed_milestones} = 0;
    $self->{_start_timestamp} = time;

    return $self;
}

=head2 if_remaining_seconds_is_known

B<Get:>

B<Return:>

=cut

sub if_remaining_seconds_is_known {
    my ($self) = @_;

    if ($self->{_passed_milestones} > 0) {
        return $true;
    } else {
        return $false;
    }
}

=head2 get_remaining_seconds

B<Get:>

B<Return:>

=cut

sub get_remaining_seconds {
    my ($self) = @_;

    croak "There is not enough data for calculation estimated time of accomplishment. Stopped" if not $self->if_remaining_seconds_is_known();

    my $current_timestamp = time;
    my $elapsed_seconds = $current_timestamp - $self->{_start_timestamp};
    my $left_milestones = $self->{_milestones} - $self->{_passed_milestones};

    my $one_milestone_completion_time = $elapsed_seconds/$self->{_passed_milestones};
    my $left_seconds = $one_milestone_completion_time * $left_milestones;

    return $left_seconds;
}

=head2 pass_milestone

B<Get:>

B<Return:>

=cut

sub pass_milestone {
    my ($self) = @_;

    $self->{_passed_milestones}++;
}

sub _is_positive_integer {
    my ($self, $maybe_number) = @_;

    return $false if $maybe_number eq '0';

    # http://www.perlmonks.org/?node_id=614452
    my $check_result = $maybe_number =~ m{
        \A      # beginning of string
        \+?     # optional plus sign
        [0-9]+  # mandatory non-zero digit
        \z      # end of string
    }xms;

    return $check_result;
}

=head1 SEE ALSO

=over

=item L<Term::ProgressBar>

=back

=head1 SOURCE CODE

The source code for this module and scripts is hosted on GitHub
L<https://github.com/bessarabov/Time-ETA>

=head1 BUGS

Please report any bugs or feature requests in GitHub Issues
L<https://github.com/bessarabov/Time-ETA/issues>

=cut

1;
