package CTF4U::DB::Row::User;
use v5.24;
use strictures 2;
use parent qw/Teng::Row/;

sub twitter_id {
    my $self = shift;
    return $self->get_column('user_id');
}

1;
