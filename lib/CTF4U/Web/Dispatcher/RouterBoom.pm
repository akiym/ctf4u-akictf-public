package CTF4U::Web::Dispatcher::RouterBoom;
use v5.24;
use strictures 2;
use utf8;

use Router::Boom::Method;

sub import {
    my $class = shift;
    my %args = @_;
    my $caller = caller(0);

    my $router = Router::Boom::Method->new();

    my $base;

    no strict 'refs';

    *{"${caller}::base"} = sub { $base = $_[0] };

    # functions
    #
    # get( '/path', 'Controller#action')
    # post('/path', 'Controller#action')
    # put('/path', 'Controller#action')
    # delete_('/path', 'Controller#action')
    # any_( '/path', 'Controller#action')
    # get( '/path', sub { })
    # post('/path', sub { })
    # put('/path', sub { })
    # delete_('/path', sub { })
    # any_( '/path', sub { })
    for my $method (qw(get post put delete_ any_)) {

        *{"${caller}::${method}"} = sub {
            my ($path, $dest) = @_;

            my %dest;
            if (ref $dest eq 'CODE') {
                $dest{code} = $dest;
            } else {
                my ($controller, $method) = split('#', $dest);
                $dest{class}      = $base ? "${base}::${controller}" : $controller;
                $dest{method}     = $method if defined $method;
            }

            my $http_method;
            if ($method eq 'get') {
                $http_method = ['GET','HEAD'];
            } elsif ($method eq 'post') {
                $http_method = 'POST';
            } elsif ($method eq 'put') {
                $http_method = 'PUT';
            } elsif ($method eq 'delete_') {
                $http_method = 'DELETE';
            }

            $router->add($http_method, $path, \%dest);
        };
    }

    # class methods
    *{"${caller}::router"} = sub { $router };

    *{"${caller}::dispatch"} = sub {
        my ($class, $c) = @_;

        my $env = $c->request->env;
        if (my ($dest, $captured, $method_not_allowed) = $class->router->match($env->{REQUEST_METHOD}, $env->{PATH_INFO})) {
            if ($method_not_allowed) {
                return $c->res_405();
            }

            if ($dest->{code}) {
                return $dest->{code}->($c, $captured);
            } else {
                my $method = $dest->{method};
                $c->{args} = $captured;
                return $dest->{class}->$method($c, $captured);
            }
        } else {
            return $c->res_404();
        }
    };
}

1;
