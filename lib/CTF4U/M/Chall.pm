package CTF4U::M::Chall;
use v5.24;
use strictures 2;
use Amon2::Declare;
use Carp;
use Data::Validator;
use JSON::Types;
use List::Util qw/sum/;

use CTF4U::Util;
use CTF4U::ChallFinder;
use CTF4U::M::Difficulty;
use CTF4U::M::Genre;
use CTF4U::Types;

sub insert {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        genre      => 'Str',
        difficulty => 'Str',
        event      => 'Str',
        name       => 'Str',
    );
    my $args = $rule->validate(@_);

    my $genre = CTF4U::M::Genre->retrieve_by_name($args->{genre})
        or croak "no such genre: $args->{genre}";
    my $difficulty = CTF4U::M::Difficulty->retrieve_by_name($args->{difficulty})
        or croak "no such difficulty: $args->{difficulty}";
    my $event = CTF4U::ChallFinder->find_event($args->{event})
        or croak "no such event: $args->{event}";

    return $c->db->fast_insert('c4u_chall' => {
        genre_id      => $genre->id,
        difficulty_id => $difficulty->id,
        event_id      => $event->id,
        name          => $args->{name},
        struct        => {},
    });
}

sub retrieve {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        id => 'Id',
    )->with('StrictSequenced');
    my $args = $rule->validate(@_);

    return $c->db->single('c4u_chall' => {
        id => $args->{id},
    });
}

sub retrieve_by {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        event_id => {isa => 'Id', optional => 1},
        name     => {isa => 'Str', optional => 1},
    );
    my $args = $rule->validate(@_);

    return $c->db->single('c4u_chall' => $args);
}

sub all {
    my $class = shift;
    my $c = c();

    return [$c->db->search('c4u_chall' => {})];
}

sub search_as_arrayref {
    my $class = shift;
    my $c = c();

    return $_ for cache 'challenges';

    my @challs = $c->db->search_by_sql(
        q{
select
    chall.id
    , chall.name
    , chall.solves
    , chall.event_id
    , chall.difficulty_id
    , chall.struct
    , difficulty.name as difficulty
    , event.name as event
    , event.event_source_id as event_source_id
    , event.year
    , event.struct as event_struct
from c4u_chall as chall
    inner join c4u_difficulty as difficulty on difficulty_id = difficulty.id
    inner join c4u_event as event on event_id = event.id
order by difficulty_id, year desc, event_id desc, chall.id
        },
        [],
        'c4u_chall'
    )->all;
    return cache 'challenges', [map +{
        id              => number($_->{row_data}{id}),
        name            => $_->{row_data}{name},
        difficulty      => $_->{row_data}{difficulty},
        difficulty_id   => number($_->{row_data}{difficulty_id}),
        event           => $_->{row_data}{event},
        event_source_id => number($_->{row_data}{event_source_id}),
        year            => number($_->{row_data}{year}),
        solves          => number($_->{row_data}{solves}),
        github_link     => $_->struct->{github_link},
        download_link   => ($_->struct->{download_link} || $_->event_struct->{download_link}),
        source_link     => ($_->struct->{url} || $_->event_struct->{url}),
        dont_spoil      => bool($_->event_struct->{dont_spoil}),
        (exists $_->{row_data}{checked} ?
            (checked => bool($_->{row_data}{checked})) : ()),
    }, @challs];
}

sub update {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        id            => 'Id',
        event_id      => {isa => 'Id', optional => 1},
        difficulty_id => {isa => 'Id', optional => 1},
    );
    my $args = $rule->validate(@_);

    my $txn = $c->db->txn_scope;
    my $chall = $c->db->single('c4u_chall', {id => $args->{id}});
    if ($chall) {
        $chall->update({
            (exists $args->{event_id} ?
                (event_id => $args->{event_id}) : ()),
            (exists $args->{difficulty_id} ?
                (difficulty_id => $args->{difficulty_id}) : ()),
        });
    } else {
        warn;
    }
    $txn->commit;
}

sub update_solves {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        id     => 'Id',
        amount => 'Num', # 1, -1
    );
    my $args = $rule->validate(@_);

    my $txn = $c->db->txn_scope;
    my $chall = $class->retrieve($args->{id});
    if ($chall) {
        $chall->update({
            solves => $chall->solves + $args->{amount},
        });
    }
    $txn->commit;
}

sub update_struct {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        id     => 'Id',
        struct => 'HashRef',
    );
    my $args = $rule->validate(@_);

    my $txn = $c->db->txn_scope;
    my $chall = $class->retrieve($args->{id});
    if ($chall) {
        my $struct = $chall->struct;
        # 同一のキーがあれば上書き
        $chall->update({
            struct => {
                %$struct,
                $args->{struct}->%*,
            },
        });
    }
    $txn->commit;
}

sub options {
    my $class = shift;
    my $c = c();

    return $_ for cache 'options';

    return cache 'options', {
        difficulty => [map +{
            value => number($_->id),
            label => $_->name,
        }, CTF4U::M::Difficulty->all->@*],
        year         => [map +{
            value => number($_),
            label => string($_),
        }, CTF4U::M::Event->search_year_selection->@*],
        event_source => [map +{
            value => number($_->{value}),
            label => $_->{label},
        }, CTF4U::M::Event->event_sources->@*],
    };
}

sub status {
    my $class = shift;
    my $c = c();

    return $_ for cache 'status';

    my @chall_num;
    for my $chall (CTF4U::M::Chall->all->@*) {
        $chall_num[$chall->difficulty_id]++;
    }
    # difficulty_idが0は存在しないので削除
    shift @chall_num;
    return cache 'status', {
        solves       => number(sum(@chall_num)),
        solves_count => [map { number($_) } @chall_num],
    };
}

sub count {
    my $class = shift;
    my $c = c();

    return $c->db->count('c4u_chall');
}

1;
