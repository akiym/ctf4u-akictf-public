use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '..', 'lib');
use Plack::Builder;
use Plack::Builder::Conditionals;
use Plack::App::File;

use Plack::Session::Store::DBI;
use Plack::Session::State::Cookie;

use CTF4U;
use CTF4U::Web;

my $conf = CTF4U->config;

my $app = builder {
    enable 'ReverseProxy';
    enable 'AxsLog',
        response_time      => 1,
        long_response_time => 500_000;
    enable 'ServerStatus::Lite', $conf->{'ServerStatus::Lite'}->%*;

    enable 'Log::Minimal';

    enable 'QueryLog',
        threshold => 0.005,
        skip_package => [qw/Teng/];

    enable 'Session',
        store => Plack::Session::Store::DBI->new(
            get_dbh => sub {
                DBI->connect( $conf->{DBI}->@* )
                    or die $DBI::errstr;
            }
        ),
        state => Plack::Session::State::Cookie->new(
            session_key => 'akictf_session',
            httponly    => 1,
        );

    mount '/ctf4u/' => builder {
        enable match_if addr(['127.0.0.1']),
            'BetterStackTrace',
                application_caller_subroutine => 'Amon2::Web::handle_request',
                no_print_errors               => 1;

        enable 'Static',
            path => qr{^(?:/static/)},
            root => File::Spec->catdir(dirname(__FILE__), '..');
        enable 'Static',
            path => qr{^(?:/dat/)},
            root => File::Spec->catdir(dirname(__FILE__), '..');
        enable 'Static',
            path => qr{^(?:/robots\.txt|/favicon\.ico)$},
            root => File::Spec->catdir(dirname(__FILE__), '..', 'static');

        mount '/' => CTF4U::Web->to_app();
    };
};
