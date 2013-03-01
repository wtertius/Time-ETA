use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'ETA',
    AUTHOR              => q{Ivan Bessarabov <ivan@bessarabov.ru>},
    VERSION_FROM        => 'lib/ETA.pm',
    ABSTRACT_FROM       => 'lib/ETA.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'ETA-*' },
);
