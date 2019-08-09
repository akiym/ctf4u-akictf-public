package CTF4U::M::User;
use v5.24;
use strictures 2;
use Amon2::Declare;
use Data::Validator;
use Log::Minimal;

use CTF4U::M::Akictf;
use CTF4U::Types;
use CTF4U::Util;

sub register {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        twitter_id => 'Id',
    );
    my $args = $rule->validate(@_);

    my $akictf_user = CTF4U::M::Akictf->user(user_id => $args->{twitter_id});
    unless ($akictf_user) {
        croakf('could not retrieve akictf user (twitter_id:%d)', $args->{twitter_id});
    }

    $c->db->insert('c4u_user', {
        user_id     => $args->{twitter_id},
        screen_name => $akictf_user->{screen_name},
        solves      => 0,
        struct      => {},
    });

    # ユーザが新規登録されたときにキャッシュを破棄
    purge_cache 'search_user';
}

sub retrieve_by_twitter_id {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        twitter_id => 'Id',
    )->with('StrictSequenced');
    my $args = $rule->validate(@_);

    return $c->db->single('c4u_user', {user_id => $args->{twitter_id}});
}

sub search_by_names {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        screen_names => 'ArrayRef[Str]',
    )->with('StrictSequenced');
    my $args = $rule->validate(@_);

    return [$c->db->search('c4u_user' => {
        screen_name => $args->{screen_names},
    }, {limit => 50})];
}

# TODO naming
# 検索
sub search_by_screen_name {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        query => 'Str',
    )->with('StrictSequenced');
    my $args = $rule->validate(@_);

    # 101: limit+1

    my $search_all = $args->{query} eq '';

    my @users;
    if ($search_all) {
        return $_ for cache 'search_user';
        @users = $c->db->search_by_sql(
            q{
select
    user.id
    , user.screen_name
    , user.solves
from c4u_user as user
where user.solves > 0
order by user.screen_name
limit 101
            },
            [],
            'c4u_user'
        );
    } else {
        my $like_query = $args->{query};
        $like_query =~ s/([%_])/\\$1/g;
        $like_query = "%$like_query%";
        @users = $c->db->search_by_sql(
            q{
select
    user.id
    , user.screen_name
    , user.solves
from c4u_user as user
where user.screen_name like ? and user.solves > 0
order by user.screen_name
limit 101
            },
            [$like_query],
            'c4u_user'
        );
    }
    my $result = CTF4U::M::Solution->search_by_users(
        screen_names => [map { $_->screen_name } @users],
    );
    if ($search_all) {
        cache 'search_user', $result;
    }
    return $result;
}

sub search_icon_urls_by_user_ids {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        user_ids => 'ArrayRef[Id]',
    );
    my $args = $rule->validate(@_);

    return CTF4U::M::Akictf->icon_url(user_ids => $args->{user_ids});
}

sub update {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        id     => 'Id',
        solves => 'Num',
    );
    my $args = $rule->validate(@_);

    my $txn = $c->db->txn_scope;
    my $user = $c->db->single('c4u_user', {id => $args->{id}});
    if ($user) {
        $user->update({
            solves => $user->solves + $args->{solves},
        });
    }
    $txn->commit;
}

1;
