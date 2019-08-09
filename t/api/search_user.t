use t::Test;

use CTF4U::Test::User;
use CTF4U::Test::Solution;
use CTF4U::Test::Chall;

my $guard = stub_internal_api_for_icon_url([]);

my $mech = create_mech;
$mech->get_ok('/ctf4u/api/search/user');
$mech->get_ok('/ctf4u/api/search/user?q=test');

subtest '基本' => sub {
    my $user = create_user(checked => [1]);
    my $user_no_checked = create_user;
    my $me = create_user(checked => [1]);

    my $guard_session = mock_session(user_id => $me->user_id);

    my $guard = stub_internal_api_for_icon_url([$user, $user_no_checked, $me]);

    $mech->get_ok('/ctf4u/api/search/user?q=' . $me->screen_name);
    is $mech->content_json, [], '自分は検索から除外される';

    $mech->get_ok('/ctf4u/api/search/user?q=' . $user_no_checked->screen_name);
    is $mech->content_json, [], 'solvesが0のユーザは検索から除外される';

    $mech->get_ok('/ctf4u/api/search/user?q=' . $user->screen_name);
    is $mech->content_json, [
        {
            screen_name  => $user->screen_name,
            solves       => 1,
            solves_count => [1, 0, 0, 0, 0, 0],
        },
    ];
};

done_testing;
