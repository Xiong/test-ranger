use 5.10.1;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Test::Ranger',
    license             => 'artistic_2',
    dist_author         => 'Xiong Changnian <xiong@cpan.org>',
    dist_version_from   => 'lib/Test/Ranger.pm',
    requires => {
        'perl'              => 5.010001,
        'Test::More'        => 0.94,
        'version'           => 0.77,
    },
    build_requires => {
        'Acme::Teddy'       => 1.002003,
    },
    add_to_cleanup      => [ 'Test-Ranger-*' ],
    meta_merge              => {
        resources               => {
            repository              => 'http://github.com/Xiong/test-ranger',
        },
        keywords            => [ qw(
            test        testing 
            debug       debugging 
            devel       development 
            frame       framework
            
            table       tablular        table-driven
            procedural
            capture     capturing
            template    templating
                    
        ) ],
    },
);

$builder->create_build_script();
