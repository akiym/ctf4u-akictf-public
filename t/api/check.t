use t::Test;

use CTF4U::Test::User;
use CTF4U::Test::Chall;

my $user = create_user;
is $user->solves, 0;
my $guard = mock_session(user_id => $user->user_id);

my $chall = find_chall(1);
my $initial_solves = $chall->solves;

my $mech = create_mech;
$mech->post_json('/ctf4u/api/check', {id => 1, checked => JSON::Types::bool(1)});
is $mech->status, 200;
is $mech->content_json, {checked => JSON::Types::bool(1), solves => $initial_solves + 1};
$chall = $chall->refetch;
is $chall->solves, $initial_solves + 1;

$user = $user->refetch;

my $solution = CTF4U::M::Solution->retrieve(
    user_id  => $user->id,
    chall_id => $chall->id,
);
isa_ok $solution, 'CTF4U::DB::Row::Solution';
is $solution, object {
    call user_id    => $user->id;
    call chall_id   => 1;
    call updated_at => '0000-00-00 00:00:00';
};

is $user->solves, 1;

$mech->post_json('/ctf4u/api/check', {id => 1, checked => JSON::Types::bool(0)});
is $mech->status, 200;
is $mech->content_json, {checked => JSON::Types::bool(0), solves => $initial_solves};

ok !CTF4U::M::Solution->retrieve(
    user_id  => $user->id,
    chall_id => 1,
);
$user = $user->refetch;
is $user->solves, 0;

done_testing;
