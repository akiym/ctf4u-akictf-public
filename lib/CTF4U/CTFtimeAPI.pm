package CTF4U::CTFtimeAPI;
# ABSTRACT: CTFtime API (https://ctftime.org/api)
use v5.24;
use strictures 2;
use Amon2::Declare;
use Data::Validator;
use JSON;
use URI;

use CTF4U::Types;

## Helper functions

sub api {
    my $c = c();
    my $url = url(@_);
    my $res = $c->http->get($url);
    die $res->status_line if $res->is_error;
    return decode_json($res->content);
}

sub url {
    my $format = shift;
    my $params = {};
    if (@_ && ref $_[-1] eq 'HASH') {
        $params = pop;
    }
    my $path = sprintf $format, @_;
    my $uri = URI->new_abs($path, 'https://ctftime.org/api/v1/');
    $uri->query_form($params);
    return $uri->as_string;
}

## Raw APIs

sub top_10_teams {
    my $class = shift;
    return api('top/');
}

sub top_10_teams_per_year {
    my $class = shift;
    state $rule = Data::Validator->new(
        year => 'Int',
    );
    my $args = $rule->validate(@_);
    return api('top/%d/', $args->{year});
}

sub events_information {
    my $class = shift;
    state $rule = Data::Validator->new(
        limit  => {isa => 'Int', default => 100},
        start  => {isa => 'Int', optional => 1},
        finish => {isa => 'Int', optional => 1},
    );
    my $args = $rule->validate(@_);
    return api('events/', $args);
}

sub specific_event_information {
    my $class = shift;
    state $rule = Data::Validator->new(
        event_id => 'Id',
    );
    my $args = $rule->validate(@_);
    return api('events/%d/', $args->{event_id});
}

sub information_about_ctfs {
    my $class = shift;
    return api('ctfs/');
}

sub information_about_specific_ctf {
    my $class = shift;
    state $rule = Data::Validator->new(
        ctf_id => 'Id',
    );
    my $args = $rule->validate(@_);
    return api('ctf/%d/', $args->{ctf_id});
}

sub information_about_teams {
    my $class = shift;
    return api('teams/');
}

sub information_about_specific_team {
    my $class = shift;
    state $rule = Data::Validator->new(
        team_id => 'Id',
    );
    my $args = $rule->validate(@_);
    return api('team/%d/', $args->{team_id});
}

sub event_results {
    my $class = shift;
    return api('results/');
}

sub event_results_per_year {
    my $class = shift;
    state $rule = Data::Validator->new(
        year => 'Int',
    );
    my $args = $rule->validate(@_);
    return api('results/%d/', $args->{year});
}

1;
