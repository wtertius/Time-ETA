package ETA;

use warnings;
use strict;

use Carp;

=head1 NAME

ETA - The great new ETA!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

my $true = 1;
my $false = '';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use ETA;

    my $foo = ETA->new();
    ...

=head1 METHODS

=head2 new

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

=head1 AUTHOR

Ivan Bessarabov, C<< <ivan at bessarabov.ru> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-eta at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ETA>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ETA


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ETA>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ETA>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ETA>

=item * Search CPAN

L<http://search.cpan.org/dist/ETA/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Ivan Bessarabov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of ETA
