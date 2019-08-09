package CTF4U::M::Akictf;
use v5.24;
use strictures 2;
use Carp;
use Amon2::Declare;
use Data::Validator;
use JSON::XS;
use Log::Minimal;

use CTF4U::Types;

sub _request_internal_api {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        api  => 'Str',
        args => 'HashRef',
    )->with('StrictSequenced');
    my $args = $rule->validate(@_);

    my $res = $c->http->post($c->config->{akictf}{internal} . $args->{api},
        'Content-Type' => 'application/json',
        Content        => encode_json($args->{args}),
    );
    croak $res->status_line if $res->is_error;

    debugf($res->content);

    return eval { decode_json($res->content) };
}

# akictfからユーザ情報を取得してくる
sub user {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        user_id => 'Id',
    );
    my $args = $rule->validate(@_);

    # {
    #     screen_name => Str,
    #     icon_url    => Str,
    # }
    return $class->_request_internal_api('user', $args);
}

# twitterのアイコン画像を取得するAPI
# akictfではアイコン画像の再取得を毎日行っている
sub icon_url {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        user_ids => 'ArrayRef[Id]',
    );
    my $args = $rule->validate(@_);

    # {
    #     user_id => Str, # user_idのアイコン画像のURL
    # }
    return $class->_request_internal_api('icon_url', $args);
}

1;
