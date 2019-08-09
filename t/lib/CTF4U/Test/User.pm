package CTF4U::Test::User;
use v5.24;
use strictures 2;
use t::Util;

use Data::Validator;
use JSON::XS;
use Module::Functions qw/get_public_functions/;
use Test::WWW::Stub;

use CTF4U::M::User;
use CTF4U::Types;

use Exporter 'import';
our @EXPORT = get_public_functions();

use constant DEFAULT_ICON_URL => 'http://abs.twimg.com/sticky/default_profile_images/default_profile_mini.png';

sub create_user {
    state $rule = Data::Validator->new(
        twitter_id  => {isa => 'Id', default => sub { random_id }},
        screen_name => {isa => 'Str', default => sub { random_alnum(6) }},
        checked     => {isa => 'ArrayRef[Int]', default => sub { [] }},
    );
    my $args = $rule->validate(@_);

    my $guard = stub_internal_api_for_user(
        screen_name => $args->{screen_name},
    );

    CTF4U::M::User->register(
        twitter_id => $args->{twitter_id},
    );

    my $user = CTF4U::M::User->retrieve_by_twitter_id($args->{twitter_id});

    for my $chall_id ($args->{checked}->@*) {
        CTF4U::M::Solution->update(
            user_id  => $user->id,
            chall_id => $chall_id,
            solved   => 1,
        );
    }

    return $user->refetch;
}

sub stub_internal_api_for_user {
    state $rule = Data::Validator->new(
        screen_name => {isa => 'Str', default => random_alnum(6)},
        icon_url    => {isa => 'Str', default => DEFAULT_ICON_URL},
    );
    my $args = $rule->validate(@_);

    return Test::WWW::Stub->register('http://akictf.test/api/internal/user', [
        200,
        ['Content-Type' => 'application/json'],
        [
            encode_json({
                screen_name => $args->{screen_name},
                icon_url    => $args->{icon_url},
            })
        ],
    ]);
}

sub stub_internal_api_for_icon_url {
    state $rule = Data::Validator->new(
        users => 'ArrayRef[User]',
    )->with('StrictSequenced');
    my $args = $rule->validate(@_);

    return Test::WWW::Stub->register('http://akictf.test/api/internal/icon_url', [
        200,
        ['Content-Type' => 'application/json'],
        [encode_json({
            map {
                ($_->user_id => DEFAULT_ICON_URL)
            } $args->{users}->@*
        })],
    ]);
}

1;
