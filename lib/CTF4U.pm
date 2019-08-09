package CTF4U;
use v5.24;
use strictures 2;
use parent qw/Amon2/;
use Amon2::Config::Simple;

use Cache::FileCache;
use Hash::Util;
use JSON::XS ();
use LWP::UserAgent;

use CTF4U::DB;
use CTF4U::DB::Schema;
use CTF4U::M::User;
use CTF4U::M::Chall;
use CTF4U::M::Event;
use CTF4U::M::Difficulty;
use CTF4U::M::Genre;
use CTF4U::M::Solution;

our $VERSION = '0.01';

my $schema = CTF4U::DB::Schema->instance;

sub load_config {
    my $class = shift;
    my $config = Amon2::Config::Simple->load($class);
    Hash::Util::lock_keys(%$config);
    return $config;
}

sub db {
    my $c = shift;
    unless (exists $c->{db}) {
        $c->{db} = CTF4U::DB->new(
            schema       => $schema,
            connect_info => $c->config->{DBI},
        );
    }
    return $c->{db};
}

sub cache {
    my $c = shift;
    return $c->{cache} //= Cache::FileCache->new(
        $c->config->{'Cache::FileCache'}
    );
}

sub http {
    my $c = shift;
    return $c->{http} //= LWP::UserAgent->new(agent => 'CTF4U');
}

sub json {
    my $c = shift;
    return $c->{json} //= JSON::XS->new;
}

sub is_logged_in {
    my $c = shift;
    return !!$c->session->get('user_id');
}

# twitter id
sub twitter_id {
    my $c = shift;
    return $c->session->get('user_id');
}

sub user {
    my $c = shift;
    return undef unless my $twitter_id = $c->twitter_id;
    if (my $user = CTF4U::M::User->retrieve_by_twitter_id($twitter_id)) {
        return $user;
    } else {
        # ユーザが存在しない場合新しく登録する
        CTF4U::M::User->register(
            twitter_id => $twitter_id,
        );
        return CTF4U::M::User->retrieve_by_twitter_id($twitter_id);
    }
}

1;
__END__

=head1 NAME

CTF4U - CTF4U

=head1 DESCRIPTION

This is a main context class for CTF4U

=head1 AUTHOR

CTF4U authors.

