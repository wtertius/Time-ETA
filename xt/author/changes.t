use Time::ETA;
use File::Slurp;
use Test::More;

my $content = read_file('Changes');

my $v = $Time::ETA::VERSION;
ok(defined $v, "Version is defined");
like($content, qr/^$v/ms, "Changes has info about version '$v'");

done_testing();
