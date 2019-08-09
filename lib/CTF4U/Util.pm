package CTF4U::Util;
use v5.24;
use strictures 2;
use Amon2::Declare;
use Carp;
use List::Util qw/any/;
use Module::Functions qw/get_public_functions/;

use Exporter 'import';
our @EXPORT = get_public_functions();

my @CACHE_KEYS = qw(
    challenges
    options
    status
    search_user
);

sub _check_key {
    my $key = shift;
    croak "invalid cache key: $key" unless any { $key eq $_ } @CACHE_KEYS;
}

sub cache {
    my $key = shift;
    my $c = c();

    _check_key($key);

    if (@_) {
        $c->cache->set($key, @_);
        return $_[0];
    } else {
        my $value = $c->cache->get($key);
        return unless defined $value;
        return $value;
    }
}

sub purge_cache {
    my $key = shift;
    my $c = c();

    _check_key($key);

    $c->cache->remove($key);
}

sub purge_all_cache {
    my $c = c();
    $c->cache->remove($_) for @CACHE_KEYS;
}

1;
