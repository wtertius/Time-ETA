package Time::ETA;

# ABSTRACT: calculate estimated time of accomplishment

=head1 SYNOPSIS

    use Time::ETA;

    my $eta = Time::ETA->new(
        milestones => 12,
    );

    foreach (1..12) {
        do_work();
        $eta->pass_milestone();
        print "Will work " . $eta->get_remaining_seconds() . " seconds more\n";
    }

=head1 DESCRIPTION

You have a long lasting progress that consist of the number of more or less
equal tasks. You need to calculate when the progress will finish. This module
is designed to solve this task.

Time::ETA is designed to work with the programms that don't output anything
to user console. This module is created to calculate ETA in cron scripts and
background running programms. If you need an easy way to output process
progress in terminal, please look at the exelent L<Term::ProgressBar>.

To work with Time::ETA you need to create object with constructor new().

Then you run your tasks (just execute subs that containg the code of that
tasks) and after each task you run pass_milestone() method to tell Time::ETA
object that you have completed part of your process.

Any time in you programme you can use methods to understand what is going on
and how soon the process will finish. That are methods
get_completed_percent(), get_elapsed_seconds(), get_remaining_seconds().

This module has build-in feature for serialisation. You can run method
serialize() to get the text string with the object state. And you can restore
your object from that string with spawn() method.

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

=head1 METHODS

=head2 new

B<Get:> 1) $class 2) %params

B<Return:> 1) $self with Time::ETA object

This is the constructor. It needs one mandatory parameter - the number of
milestones that should be completed.

Here is the example. Let's imagine that we are generating timetable for the
next year. We have method generate_month() that is executed for every month.
To create Time::ETA object that can calculate estimated time of timetable
generation you need to write:

    my $eta = Time::ETA->new(
        milestones => 12,
    );

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

=head2 get_elapsed_seconds

B<Get:> 1) $self

B<Return:> 1) $elapsed_seconds - float number

Method return number of seconds that have passed from object creation time.

    print $eta->get_elapsed_seconds();

It can output something like 1.35024 and it means that a bit more than one
second have passed from the moment the new() constructor has executed.

If the process is finished this method will return process run time in
seconds.

=cut

sub get_elapsed_seconds {
    my ($self) = @_;

    my $elapsed_seconds;

    if ($self->is_completed()) {
        $elapsed_seconds = tv_interval($self->{_start}, $self->{_end});
    } else {
        $elapsed_seconds = tv_interval($self->{_start}, [gettimeofday]);
    }

    return $elapsed_seconds;
}

=head2 get_remaining_seconds

B<Get:> 1) $self

B<Return:> 1) $elapsed_seconds - float number

Method return estimated seconds how long the process will work.

    print $eta->get_remaining_seconds();

It can return number like 14.872352 that means that the process will end in
nearly 15 seconds. The accuaccuracy of this time depends on the time lengths
of every milestone. The more equal milestones time to each other, the more
precise is the prediction.

This method will die in case it haven't got enough information to calculate
estimated time of accomplishment. The method will die untill pass_milestone()
is run for the first time. AFter pass_milestone() run at least once,
get_remaining_seconds() has enouth data to caluate ETA. To find out if ETA can
be calculated you can use method can_calculate_eta().

If the process is finished this method will return 0.

=cut

sub get_remaining_seconds {
    my ($self) = @_;

    croak "There is not enough data to calculate estimated time of accomplishment. Stopped" if not $self->can_calculate_eta();

    my $elapsed_seconds = $self->get_elapsed_seconds();
    my $remaining_milestones = $self->{_milestones} - $self->{_passed_milestones};

    my $one_milestone_completion_time = $elapsed_seconds/$self->{_passed_milestones};
    my $remaining_seconds = $one_milestone_completion_time * $remaining_milestones;

    return $remaining_seconds;
}

=head2 get_completed_percent

B<Get:> 1) $self

B<Return:> 1) $completed_percent - float number in the range from zero to 100
(including zero and 100)

Method returns the percentage of the process completion. It will return 0 if
no milestones have been passed and it will return 100 if all the milestones
have been passed.

    $eta->get_completed_percent();

For example, if one milestone from 12 have been completed it will print
8.33333333333333

=cut

sub get_completed_percent {
    my ($self) = @_;

    my $completed_percent = (100 * $self->{_passed_milestones}) / $self->{_milestones};

    return $completed_percent;
}

=head2 is_completed

B<Get:> 1) $self

B<Return:> 1) $boolean - true value if the process is completed or false value
if the process is running.

You can also use get_completed_percent() to find our how much of the process
is finished.

=cut

sub is_completed {
    my ($self) = @_;

    return ($self->{_passed_milestones} == $self->{_milestones})
        ? $true
        : $false
        ;
}

=head2 pass_milestone

B<Get:> 1) $self

B<Return:> it returns nothing that can be used

This method tells the object that one part of the task (called milestone) have
been completed. You need to run this method as many times as many milestones
you have specified in the object new() constructor.

    $eta->pass_milestone();

You need to run this method at least once to make method
get_remaining_seconds() work.

=cut

sub pass_milestone {
    my ($self) = @_;

    if ($self->{_passed_milestones} < $self->{_milestones}) {
        $self->{_passed_milestones}++;
    } else {
        croak "You have already completed all milestones. It it incorrect to run pass_milestone() now. Stopped";
    }

    if ($self->{_passed_milestones} == $self->{_milestones}) {
        $self->{_end} = [gettimeofday];
    }

    return $false;
}

=head2 can_calculate_eta

B<Get:> 1) $self

B<Return:> $boolean

This method returns bool value that that gives information if there is enough
data in the object to calculate process estimated time of accomplishment.

It will return true value if method pass_milestone() have been run at least
once, if the method pass_milestone() haven't been run it will return false.

This method is used to check if it is safe to run method
get_remaining_seconds(). Method get_remaining_seconds() dies in case there is
no data to calculate ETA.

    if ( $eta->can_calculate_eta() ) {
        print $eta->get_remaining_seconds();
    }

When the process is complete can_calculate_eta() returns true value, but
get_remaining_seconds() return 0.

=cut

sub can_calculate_eta {
    my ($self) = @_;

    if ($self->{_passed_milestones} > 0) {
        return $true;
    } else {
        return $false;
    }
}

=head2 serialize

B<Get:> 1) $self

B<Return:> 1) $string with serialized object

Object Time::ETA has build-in serialaztion feature. For example you need to
store the state of this object in the database. You can run:

    my $string = $eta->serialize();

As a result you will get $string with text data that represents the whole
object with its state. Then you can store that $string in the database and
later with the method spawn() to recreate the object in the same state it was
before the serialization.

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

B<Get:> 1) $class 2) $string with serialized object

B<Return:> 1) $self

This is actually an object constructor. It recieves $string that contaings
serialized object data and creates an object.

    my $eta = Time::ETA->spawn($string);

The $string is created by the method serialized().

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

=item L<PBS::ProgressBar>

=item L<Progress::Any>

=item L<Progress::PV>

=item L<Term::ProgressBar::Quiet>

=item L<Term::ProgressBar::Simple>

=item L<Term::ProgressBar>

=item L<Text::ProgressBar::ETA>

=item L<Time::Progress>

=back

=head1 SOURCE CODE

The source code for this module and scripts is hosted on GitHub
L<https://github.com/bessarabov/Time-ETA>

=head1 BUGS

Please report any bugs or feature requests in GitHub Issues
L<https://github.com/bessarabov/Time-ETA/issues>

=cut

1;
