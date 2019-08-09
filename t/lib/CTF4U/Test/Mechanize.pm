package CTF4U::Test::Mechanize;
use v5.24;
use strictures 2;
use parent qw/Test::WWW::Mechanize::PSGI/;
use JSON::XS;

sub post_json {
    my ($self, $url, $content) = @_;
    $self->post($url,
        'Content-Type' => 'application/json',
        Content        => encode_json($content),
    );
}

sub content_json {
    my ($self) = @_;
    return decode_json($self->content);
}

1;
