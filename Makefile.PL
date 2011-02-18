use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WWW::Folksonomy',
    AUTHOR              => 'Todd W. Harris <harris@cshl.edu>',
    VERSION_FROM        => 'lib/WWW/Folksonomy.pm',
    ABSTRACT_FROM       => 'lib/WWW/Folksonomy.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WWW-Folksonomy-*' },
);
