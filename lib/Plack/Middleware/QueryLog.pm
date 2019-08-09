package Plack::Middleware::QueryLog;
use strict;
use warnings;
use parent qw(Plack::Middleware);
use Carp;
use Plack::Util::Accessor qw(formatter threshold skip_package);
use DBIx::QueryLog;

our $VERSION = '0.01';

sub build_logger {
    my ($self, $env) = @_;
    return sub {
        $env->{'psgi.errors'}->print($self->formatter->($env, @_));
    };
}


sub prepare_app {
    my $self = shift;
    $self->formatter(sub{
        my ($env, %params) = @_;
        sprintf "%s [%s] [%s] [%s] %s at %s line %s\n",
            $params{localtime}, $params{pkg}, $env->{REQUEST_URI}, $params{time},
            $params{sql},
            $params{file}, $params{line};
    }) unless $self->formatter;
    DBIx::QueryLog->threshold($self->threshold) if $self->threshold;
    if ($self->skip_package) {
        if (ref $self->skip_package && ref $self->skip_package eq 'ARRAY') {
            for my $package (@{$self->skip_package}) {
                $DBIx::QueryLog::SKIP_PKG_MAP{$package} = 1;
            }
        } else {
            croak("skip_package must be ArrayRef");
        }
    }
}

sub call {
    my ($self, $env) = @_;
    local $DBIx::QueryLog::OUTPUT = $self->build_logger($env);
    $self->app->($env);
}

1;
