use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Folksonomy',
    license             => 'perl',
    dist_author         => 'Todd W. Harris <harris@cshl.edu>',
    dist_version_from   => 'lib/WWW/Folksonomy.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'WWW-Folksonomy-*' ],
);

$builder->create_build_script();
