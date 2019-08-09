use t::Test;
use JSON::Types ();
use JSON::XS;

use CTF4U::Test::User;

subtest 'create_user' => sub {
    my $twitter_id = random_id;
    my $screen_name = random_alnum(6);

    my $user = create_user(
        twitter_id  => $twitter_id,
        screen_name => $screen_name,
    );
    isa_ok $user, 'CTF4U::DB::Row::User';
    is $user, object {
        call twitter_id  => $twitter_id;
        call screen_name => $screen_name;
    };
    ok $user->refetch;

    subtest 'checked' => sub {
        my @checked = (1, 2, 3, 10);
        my $user = create_user(
            checked => \@checked,
        );
        is $user->solves, 4;

        my $guard = stub_internal_api_for_icon_url([$user]);

        my $solution = CTF4U::M::Solution->search_by_users(
            screen_names => [$user->screen_name],
        );
        is $solution->[0], {
            checked      => {
                map {
                    ($_ => JSON::Types::bool(1)),
                } @checked
            },
            icon_url     => CTF4U::Test::User::DEFAULT_ICON_URL,
            screen_name  => $user->screen_name,
            solves       => 4,
            solves_count => [4, 0, 0, 0, 0, 0],
        };
    };
};

subtest 'stub_internal_api_for_user' => sub {
    my $ua = LWP::UserAgent->new;
    my $screen_name = 'akiym';
    my $icon_url = 'http://twimg.test/akiym.jpg';
    my $guard = stub_internal_api_for_user(
        screen_name => $screen_name,
        icon_url    => $icon_url,
    );
    my $res = $ua->get('http://akictf.test/api/internal/user');
    is $res->code, 200;
    is $res->content_type, 'application/json';
    is decode_json($res->content), {
        screen_name => $screen_name,
        icon_url    => $icon_url,
    };
};

done_testing;
