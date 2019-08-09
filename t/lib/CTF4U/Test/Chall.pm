package CTF4U::Test::Chall;
use v5.24;
use strictures 2;
use t::Util;

use Data::Validator;
use Module::Functions qw/get_public_functions/;

use CTF4U::M::Chall;

use Exporter 'import';
our @EXPORT = get_public_functions();

sub find_chall {
    state $rule = Data::Validator->new(
        id => 'Int',
    )->with('StrictSequenced');
    my $args = $rule->validate(@_);

    return CTF4U::M::Chall->retrieve($args->{id});
}

1;
