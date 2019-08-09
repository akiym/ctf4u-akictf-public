use t::Test;

use CTF4U::Test::User;

my $mech = create_mech;
$mech->post_json('/ctf4u/api/rival', {rivals => []});
is $mech->status, 200;
is $mech->content, '[null]', 'ログインしていない場合には0番目がnull';

subtest 'ログイン時' => sub {
    my $me = create_user;
    my $guard_session = mock_session(user_id => $me->user_id);

    my $my_info = {
        checked      => {},
        icon_url     => CTF4U::Test::User::DEFAULT_ICON_URL,
        screen_name  => $me->screen_name,
        solves       => 0,
        solves_count => [0,0,0,0,0,0],
    };

    my $guard = stub_internal_api_for_icon_url([$me]);

    $mech->post_json('/ctf4u/api/rival', {rivals => []});
    is $mech->status, 200;
    is $mech->content_json, [$my_info], '自分の情報が0番目に入っている';

    subtest '複数のライバル' => sub {
        my @users = map { create_user } 1..3;

        my $guard = stub_internal_api_for_icon_url([$me, @users]);

        $mech->post_json('/ctf4u/api/rival', {rivals => [map { $_->screen_name } @users]});
        is $mech->status, 200;
        is $mech->content_json, [
            $my_info,
            map {
                +{
                    checked      => {},
                    icon_url     => CTF4U::Test::User::DEFAULT_ICON_URL,
                    screen_name  => $_->screen_name,
                    solves       => 0,
                    solves_count => [0,0,0,0,0,0],
                }
            } @users
        ];
    };
};

subtest '不正なパラメータ' => sub {
    $mech->post_json('/ctf4u/api/rival', {});
    is $mech->status, 400;
    is $mech->content_json, {}, '必須パラメータが指定されていない';

    $mech->post('/ctf4u/api/rival',
        Content => '^_^',
    );
    is $mech->status, 400, '不正なJSON';
};

done_testing;
