use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '..', 'lib');
use Proclet;

my $proclet = Proclet->new(
    color => 1,
);

$proclet->service(
    code => \&run_web,
    tag  => 'web',
);

$proclet->run;

sub run_web {
    my $port        = 5000;
    my $host        = '127.0.0.1';
    my $max_workers = 1;
    my $server      = 'HTTP::Server::PSGI';
    my $watch_dirs  = 'lib,script';

    require Getopt::Long;
    require Plack::Runner;
    my $p = Getopt::Long::Parser->new(
        config => [qw(posix_default no_ignore_case)]
    );
    $p->getoptions(
        'p|port=i'      => \$port,
        'host=s'        => \$host,
        'max-workers=i' => \$max_workers,
        'c|config=s'    => \my $config_file,
        'watch=s'       => \$watch_dirs,
    );
    if ($config_file) {
        my $config = do $config_file;
        die "$config_file: $@" if $@;
        die "$config_file: $!" unless defined $config;
        unless ( ref($config) eq 'HASH' ) {
            die "$config_file does not return HashRef.";
        }
        no warnings 'redefine';
        no warnings 'once';
        *CTF4U::load_config = sub { $config };
    }
    if ($watch_dirs) {
        $watch_dirs = join ',',
            map { File::Spec->catdir(dirname(__FILE__), '..', $_) }
            split /,/, $watch_dirs;
    }
    $ENV{AMON2_DEBUG} = 1;

    my $runner = Plack::Runner->new(
        default_middleware => 0,
    );
    $runner->parse_options(
        '--app'         => File::Spec->catdir(dirname(__FILE__), 'dev.psgi'),
        '--host'        => $host,
        '--port'        => $port,
        '--server'      => $server,
        '--max-workers' => $max_workers,
        '--Reload'      => $watch_dirs,
    );
    $runner->run;
}
