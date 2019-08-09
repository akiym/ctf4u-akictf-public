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

    mount '/ctf4u/' => CTF4U::Web->to_app();
};
