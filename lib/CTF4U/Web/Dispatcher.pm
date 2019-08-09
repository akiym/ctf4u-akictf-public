package CTF4U::Web::Dispatcher;
use v5.24;
use strictures 2;
use CTF4U::Web::Dispatcher::RouterBoom;
use Data::Validator;
use JSON::Types;
use JSON::XS;
use Log::Minimal;
use List::Util qw/uniq/;

use CTF4U::M::Chall;
use CTF4U::M::Difficulty;
use CTF4U::M::Event;
use CTF4U::M::Solution;
use CTF4U::M::User;
use CTF4U::Types;

get '/' => sub {
    my ($c) = @_;
    return $c->render('index.tx');
};

get '/how2use' => sub {
    my ($c) = @_;
    return $c->render('how2use.tx');
};

get '/api/challenge' => sub {
    my ($c) = @_;
    my $user = $c->user;
    return $c->render_json({
        challenges => CTF4U::M::Chall->search_as_arrayref(),
        options    => CTF4U::M::Chall->options(),
        status     => CTF4U::M::Chall->status(),
    });
};

post '/api/check' => sub {
    my ($c) = @_;
    state $rule = Data::Validator->new(
        id      => 'Id',
        checked => 'Bool',
    )->with('NoThrow');
    my $args = $rule->validate(eval { decode_json($c->req->content) });
    if ($rule->has_errors) {
        $rule->clear_errors;
        my $res = $c->render_json({});
        $res->code(400);
        return $res;
    }
    unless ($c->is_logged_in) {
        my $res = $c->render_json({});
        $res->code(403);
        return $c->render_json({});
    }

    my $chall = CTF4U::M::Chall->retrieve($args->{id});
    if ($chall) {
        CTF4U::M::Solution->update(
            user_id  => $c->user->id,
            chall_id => $args->{id},
            solved   => $args->{checked},
        );

        return $c->render_json({
            checked => bool($args->{checked}),
            solves  => number($chall->refetch->solves),
        });
    } else {
        return $c->render_json({});
    }
};

post '/api/rival' => sub {
    my ($c) = @_;
    state $rule = Data::Validator->new(
        rivals  => 'ArrayRef[Str]',
    )->with('NoThrow');
    my $args = $rule->validate(eval { decode_json($c->req->content) });
    if ($rule->has_errors) {
        $rule->clear_errors;
        my $res = $c->render_json({});
        $res->code(400);
        return $res;
    }

    my $user = $c->user;
    my $rivals_limit = 100;

    # [0]番目はログインしているユーザの情報
    my @rivals = ($user ? $user->screen_name : undef);

    # Twitterのscreen_nameは15文字以下
    push @rivals, grep { length($_) <= 15 } $args->{rivals}->@*;
    splice @rivals, $rivals_limit;
    @rivals = uniq @rivals;
    return $c->render_json(
        CTF4U::M::Solution->search_by_users(screen_names => \@rivals)
    );
};

get '/api/search/user' => sub {
    my ($c) = @_;
    my $q = $c->req->parameters->{q} // '';
    my $user = $c->user;
    my $users = CTF4U::M::User->search_by_screen_name($q);
    return $c->render_json([
        map +{
            screen_name  => $_->{screen_name},
            solves       => $_->{solves},
            solves_count => $_->{solves_count},
        },
        grep { !$user || $user->screen_name ne $_->{screen_name} }
        grep { defined $_ } @$users
    ]);
};

1;
