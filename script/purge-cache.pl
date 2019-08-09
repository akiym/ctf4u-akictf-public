use v5.24;
use strictures 2;
use Path::Tiny;
use Log::Minimal;

use CTF4U;
use CTF4U::Util;

my $c = CTF4U->bootstrap;

warnf('running purge-cache.pl in %s', $c->mode_name // 'unknown');
purge_all_cache;
