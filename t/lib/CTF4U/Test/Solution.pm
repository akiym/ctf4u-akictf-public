package CTF4U::Test::Solution;
use v5.24;
use strictures 2;
use t::Util;

use Data::Validator;
use Module::Functions qw/get_public_functions/;

use CTF4U::M::Solution;
use CTF4U::Types;

use Exporter 'import';
our @EXPORT = get_public_functions();

sub update_solution {
    state $rule = Data::Validator->new(
        user   => 'User',
        chall  => 'Chall',
        solved => {isa => 'Bool', default => 1},
    );
    my $args = $rule->validate(@_);

    CTF4U::M::Solution->update(
        user_id  => $args->{user}->id,
        chall_id => $args->{chall}->id,
        solved   => $args->{solved},
    );
}

1;
