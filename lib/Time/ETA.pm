package Time::ETA;

# ABSTRACT: calculate estimated time of accomplishment

=head1 SYNOPSIS

    my $number = 10;

    my $eta = Time::ETA->new(
        milestones => $number,
    );

    foreach (1 .. $number) {

        if ($eta->can_calculate_eta()) {
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
use Time::HiRes qw(
    gettimeofday
    tv_interval
);

use YAML;

my $true = 1;
my $false = '';

my $serialization_api_version = 1;

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
    $self->{_start} = [gettimeofday];

    return $self;
}

=head2 can_calculate_eta

B<Get:>

B<Return:>

=cut

sub can_calculate_eta {
    my ($self) = @_;

    if ($self->{_passed_milestones} > 0) {
        return $true;
    } else {
        return $false;
    }
}

=head2 get_elapsed_seconds

B<Get:>

B<Return:>

=cut

sub get_elapsed_seconds {
    my ($self) = @_;

    my $elapsed_seconds = tv_interval($self->{_start}, [gettimeofday]);

    return $elapsed_seconds;
}

=head2 get_remaining_seconds

B<Get:>

B<Return:>

=cut

sub get_remaining_seconds {
    my ($self) = @_;

    croak "There is not enough data to calculate estimated time of accomplishment. Stopped" if not $self->can_calculate_eta();

    my $elapsed_seconds = $self->get_elapsed_seconds();
    my $left_milestones = $self->{_milestones} - $self->{_passed_milestones};

    my $one_milestone_completion_time = $elapsed_seconds/$self->{_passed_milestones};
    my $left_seconds = $one_milestone_completion_time * $left_milestones;

    return $left_seconds;
}

=head2 get_completed_percent

B<Get:>

B<Return:>

=cut

sub get_completed_percent {
    my ($self) = @_;

    my $completed_percent = (100 * $self->{_passed_milestones}) / $self->{_milestones};

    return $completed_percent;
}

=head2 pass_milestone

B<Get:>

B<Return:>

=cut

sub pass_milestone {
    my ($self) = @_;

    $self->{_passed_milestones}++;
}

=head2 serialize

B<Get:>

B<Return:>

=cut

sub serialize {
    my ($self) = @_;

    my $data = {
        _version => $serialization_api_version,
        _milestones => $self->{_milestones},
        _passed_milestones => $self->{_passed_milestones},
        _start  => $self->{_start},
    };

    my $string = Dump($data);

    return $string;
}

=head2 spawn

B<Get:>

B<Return:>

=cut

sub spawn {
    my ($class, $string) = @_;

    croak "Can't spawn object. No serialized data specified. Stopped" if not defined $string;

    my $data;

    eval {
        $data = Load($string);
    };

    if ($@) {
        croak "Can't spawn object. Got error from YAML parser:\n" . $@ . "Stopped";
    }

    croak "Can't spawn object. Got incorrect serialized data. Stopped" if ref $data ne "HASH";

    croak "Can't spawn object. Serialized data does not contain version. Stopped" if not defined $data->{_version};

    croak "Can't spawn object. Version $Time::ETA::VERSION can work only with serialized data version $serialization_api_version. Stopped"
        if $data->{_version} ne $serialization_api_version;

    croak "Can't spawn object. Serialized data contains incorrect number of milestones. Stopped"
        if not _is_positive_integer(undef, $data->{_milestones});

    croak "Can't spawn object. Serialized data contains incorrect number of passed milestones. Stopped"
        if not _is_positive_integer_or_zero(undef, $data->{_passed_milestones});

    croak "Can't spawn object. Serialized data contains incorrect data for start time. Stopped"
        if ref $data->{_start} ne "ARRAY";

    croak "Can't spawn object. Serialized data contains incorrect seconds in start time. Stopped"
        if not _is_positive_integer_or_zero(undef, $data->{_start}->[0]);

    croak "Can't spawn object. Serialized data contains incorrect microseconds in start time. Stopped"
        if not _is_positive_integer_or_zero(undef, $data->{_start}->[1]);

    my $self = {
        _milestones => $data->{_milestones},
        _passed_milestones => $data->{_passed_milestones},
        _start  => $data->{_start},
    };

    bless $self, $class;

    return $self;
}

sub _is_positive_integer_or_zero {
    my ($self, $maybe_number) = @_;

    return $false if not defined $maybe_number;

    # http://www.perlmonks.org/?node_id=614452
    my $check_result = $maybe_number =~ m{
        \A      # beginning of string
        \+?     # optional plus sign
        [0-9]+  # mandatory digits, including zero
        \z      # end of string
    }xms;

    return $check_result;
}

sub _is_positive_integer {
    my ($self, $maybe_number) = @_;

    return $false if not defined $maybe_number;

    return $false if $maybe_number eq '0';
    return $false if $maybe_number eq '+0';

    return _is_positive_integer_or_zero(undef, $maybe_number);
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
