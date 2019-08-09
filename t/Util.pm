package t::Util;
use v5.24;
use strictures 2;
use Module::Functions qw/get_public_functions/;

use Carp;
use File::Basename;
use File::Spec;
use Plack::Session;
use Plack::Util;
use String::Random;
use Test::Mock::Guard;
use CTF4U::Test::Mechanize;

use Exporter 'import';
our @EXPORT = get_public_functions();

sub create_mech {
    my $app = Plack::Util::load_psgi(File::Spec->catdir(dirname(__FILE__), '..', 'script', 'app.psgi'));
    return CTF4U::Test::Mechanize->new(app => $app);
}

sub random_alnum {
    my ($x, $y) = @_;
    croak 'not enough arguments' if @_ == 0;

    if ($y) {
        return String::Random::random_regex("[A-Za-z0-9]{$x,$y}");
    } else {
        return String::Random::random_regex("[A-Za-z0-9]{$x}");
    }
}

sub random_id {
    return String::Random::random_regex("[1-9][0-9]{8,10}");
}

sub mock_session {
    my (%kv) = @_;
    my $session;
    return mock_guard('CTF4U::Web', {session => sub {
        my $self = shift;
        unless ($session) {
            $session = Plack::Session->new($self->request->env);
            $session->set($_ => $kv{$_}) for keys %kv;
        }
        return $session;
    }});
}

sub mock_cache {
    my (%kv) = @_;
    my $cache;
    return mock_guard('CTF4U', {cache => sub {
        my $self = shift;
        unless ($cache) {
            $cache = Cache::FileCache->new($self->config->{'Cache::FileCache'});
            $cache->set($_ => $kv{$_}) for keys %kv;
        }
        return $cache;
    }});
}

1;
