#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'ETA' ) || print "Bail out!
";
}

diag( "Testing ETA $ETA::VERSION, Perl $], $^X" );
