package CTF4U::M::Event;
use v5.24;
use strictures 2;
use Amon2::Declare;
use Carp ;
use Data::Validator;
use Time::Piece ();

use CTF4U::Types;

sub insert_from_ctftime {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        ctftime => 'HashRef',
    )->with('StrictSequenced');
    my $args = $rule->validate(@_);

    my $start = $args->{ctftime}{start};
    # 2005-12-01T00:00:00+00:00 -> 2005-12-01T00:00:00+0000
    $start =~ s/(\+\d\d):(\d\d)$/$1$2/;
    my $t = Time::Piece->strptime($start, '%Y-%m-%dT%H:%M:%S%z');
    my $event_source = $class->retrieve_source($args->{ctftime}{ctf_id})
        or croak "no such event_source: $args->{ctftime}{title} (ctf_id: $args->{ctftime}{ctf_id})";

    return $c->db->fast_insert('c4u_event', {
        event_source_id => $event_source->id,
        name            => $args->{ctftime}{title},
        year            => $t->year,
        struct          => {ctftime => $args->{ctftime}},
    });
}

sub insert_source_from_ctftime {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        ctftime => 'HashRef',
    )->with('StrictSequenced');
    my $args = $rule->validate(@_);

    return $c->db->fast_insert('c4u_event_source', {
        name   => $args->{ctftime}{title},
        ctf_id => $args->{ctftime}{id},
        struct => {ctftime => $args->{ctftime}},
    });
}

sub all {
    my $class = shift;
    my $c = c();

    return [$c->db->search('c4u_event', {})];
}

sub retrieve_by_id {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        id => 'Id',
    )->with('StrictSequenced');
    my $args = $rule->validate(@_);

    return $c->db->single('c4u_event', {id => $args->{id}});
}

sub retrieve_source {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        ctf_id => 'Id',
    )->with('StrictSequenced');
    my $args = $rule->validate(@_);

    return $c->db->single('c4u_event_source', {ctf_id => $args->{ctf_id}});
}

sub update_struct {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        id        => 'Id',
        struct    => 'HashRef',
        overwrite => {isa => 'Bool', optional => 1},
    );
    my $args = $rule->validate(@_);

    my $txn = $c->db->txn_scope;
    my $event = $class->retrieve_by_id($args->{id});
    if ($event) {
        my $struct = do {
            if ($args->{overwrite}) {
                $args->{struct};
            } else {
                # 同一のキーがあれば上書き
                +{
                    $event->struct->%*,
                    $args->{struct}->%*,
                };
            }
        };
        $event->update({
            struct => $struct,
        });
    }
    $txn->commit;
}

sub event_sources {
    my $class = shift;
    my $c = c();

    local $c->db->{suppress_row_objects} = 1;
    my @event_sources = $c->db->search_by_sql(
        q{
select event_source.id, event_source.name
from c4u_chall as chall
    inner join c4u_event as event on chall.event_id = event.id
    inner join c4u_event_source as event_source
        on event.event_source_id = event_source.id
        },
        [],
        'c4u_event_source'
    );
    my %seen;
    return [
        map +{
            value => $_->{id},
            label => $_->{name},
        },
        sort { $a->{name} cmp $b->{name} }
        grep { !$seen{$_->{id}}++ } @event_sources
    ];
}

sub search_year_selection {
    my $class = shift;
    my $c = c();

    local $c->db->{suppress_row_objects} = 1;
    return [map { $_->{year} } $c->db->search_by_sql(
        q{
            SELECT DISTINCT(year)
                FROM c4u_chall AS chall
                INNER JOIN c4u_event AS event ON chall.event_id = event.id
            WHERE year
            ORDER BY year
        },
    )];
}

1;
