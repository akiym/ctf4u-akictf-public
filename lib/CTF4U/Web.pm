package CTF4U::Web;
use v5.24;
use strictures 2;
use parent qw/CTF4U Amon2::Web/;

use CTF4U::Web::Dispatcher;
sub dispatch {
    return (CTF4U::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
    'Web::JSON' => {
        canonical => 1,
    },
);

# setup view
use CTF4U::Web::View;
{
    sub create_view {
        my $view = CTF4U::Web::View->make_instance(__PACKAGE__);
        no warnings 'redefine';
        *CTF4U::Web::create_view = sub { $view }; # Class cache.
        $view
    }
}

sub render {
    my ($self, $file, $vars) = @_;

    $vars->{USER} = $self->user;

    return $self->SUPER::render($file, $vars);
}

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;

        # http://blogs.msdn.com/b/ie/archive/2008/07/02/ie8-security-part-v-comprehensive-protection.aspx
        $res->header( 'X-Content-Type-Options' => 'nosniff' );

        # http://blog.mozilla.com/security/2010/09/08/x-frame-options/
        $res->header( 'X-Frame-Options' => 'DENY' );

        # Cache control.
        $res->header( 'Cache-Control' => 'private' );
    },
);

1;
