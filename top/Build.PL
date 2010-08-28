use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Test::Ranger',
    license             => 'perl',
    dist_author         => 'Xiong Changnian <xiong@cpan.org>',
    dist_version_from   => 'lib/Test/Ranger.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'Test-Ranger-*' ],
);

$builder->create_build_script();
