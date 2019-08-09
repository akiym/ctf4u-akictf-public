package t::Test;
use v5.24;
use strictures 2;
BEGIN {
    unless ($ENV{PLACK_ENV}) {
        $ENV{PLACK_ENV} = 'test';
    }
    if ($ENV{PLACK_ENV} eq 'production') {
        die "Do not run a test script on deployment environment";
    }
}
use File::Spec;
use File::Basename;
use lib File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), 'lib'));       # t/lib
use lib File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..', 'lib')); # lib
use Import::Into;

use CTF4U;
use CTF4U::Util;

use Time::HiRes;
my $seed = join '', Time::HiRes::gettimeofday();
$ENV{T2_RAND_SEED} //= $seed;

sub import {
    my $target = caller;

    $_->import::into($target) for qw/strict warnings utf8/;
    feature->import::into($target, ':5.24');

    $_->import::into($target) for qw(
        t::Util
        Test2::Bundle::Extended
    );

    Test::Time->import::into($target, time => 1);
    Test::Time::At->import::into($target);

    CTF4U->bootstrap;
    purge_all_cache;
}

1;
