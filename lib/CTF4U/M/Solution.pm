package CTF4U::M::Solution;
use v5.24;
use strictures 2;
use Amon2::Declare;
use Data::Validator;
use JSON::Types;
use Log::Minimal;

use CTF4U::M::Chall;
use CTF4U::M::User;
use CTF4U::Types;
use CTF4U::Util;

sub insert {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        user_id  => 'Id',
        chall_id => 'Id',
    );
    my $args = $rule->validate(@_);

    return $c->db->fast_insert('c4u_solution' => {
        user_id    => $args->{user_id},
        chall_id   => $args->{chall_id},
        updated_at => time(),
    });
}

sub delete {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        user_id  => 'Id',
        chall_id => 'Id',
    );
    my $args = $rule->validate(@_);

    return $c->db->delete('c4u_solution' => {
        user_id  => $args->{user_id},
        chall_id => $args->{chall_id},
    });
}

sub update {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        user_id  => 'Id',
        chall_id => 'Id',
        solved   => 'Bool',
    );
    my $args = $rule->validate(@_);

    my %params = (
        user_id  => $args->{user_id},
        chall_id => $args->{chall_id},
    );
    my $txn = $c->db->txn_scope;
    my $is_inserted = !!$class->retrieve(%params);
    my $amount = 0;
    if ($args->{solved}) {
        unless ($is_inserted) {
            $class->insert(%params);
            $amount = +1;
        }
    } else {
        if ($is_inserted) {
            $class->delete(%params);
            $amount = -1;
        }
    }
    if ($amount != 0) {
        CTF4U::M::Chall->update_solves(
            id     => $args->{chall_id},
            amount => $amount,
        );
        CTF4U::M::User->update(
            id     => $args->{user_id},
            solves => $amount,
        );
    }
    $txn->commit;

    # 更新されたタイミングでキャッシュを破棄
    purge_cache 'challenges';
    purge_cache 'search_user';
}

sub retrieve {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        user_id  => 'Id',
        chall_id => 'Id',
    );
    my $args = $rule->validate(@_);

    return $c->db->single('c4u_solution' => {
        user_id  => $args->{user_id},
        chall_id => $args->{chall_id},
    });
}

sub search_by_users {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        screen_names => 'ArrayRef', # Str|undef
    );
    my $args = $rule->validate(@_);

    my $users = CTF4U::M::User->search_by_names(
        [grep { defined } $args->{screen_names}->@*]
    );
    return [undef] unless @$users;

    my $user_id_to_icon_url = CTF4U::M::User->search_icon_urls_by_user_ids(
        user_ids => [map { $_->user_id } @$users],
    );

    my @solutions = $c->db->search_named(
        q{
select
    user_id
    , chall_id
    , chall.difficulty_id
from c4u_solution as solution
    inner join c4u_chall as chall on chall_id = chall.id
where user_id in :user_ids
        },
        {user_ids => [map { $_->id } @$users]},
        'c4u_solution'
    );

    my $rivals = [];
    my %id2name = map { ($_->id => $_->screen_name) } @$users;
    my %name2user = map { ($_->screen_name => $_) } @$users;
    my $difficulty_count = scalar CTF4U::M::Difficulty->all->@*;
    my %rival_name;
    for my $screen_name ($args->{screen_names}->@*) {
        unless (defined $screen_name) {
            push @$rivals, undef;
            next;
        }
        next unless exists $name2user{$screen_name};
        my $user = $name2user{$screen_name};
        $rival_name{$screen_name} = {
            checked      => {},
            solves       => $user->solves,
            solves_count => [(0) x $difficulty_count],
            screen_name  => $user->screen_name,
            icon_url     => $user_id_to_icon_url->{$user->user_id},
        };
        push @$rivals, $rival_name{$screen_name};
    }
    for my $solution (@solutions) {
        my $screen_name = $id2name{$solution->user_id};
        $rival_name{$screen_name}{checked}{$solution->chall_id} = bool(1);
        $rival_name{$screen_name}{solves_count}[$solution->difficulty_id-1]++;
    }
    return $rivals;
}

1;
