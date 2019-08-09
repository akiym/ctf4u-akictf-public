package CTF4U::Web::ViewFunctions;
use v5.24;
use strictures 2;
use Module::Functions;
use File::Spec;

use Exporter 'import';
our @EXPORT = get_public_functions();

sub space2hyphen { $_[0] =~ s/\s+/-/r }

sub commify {
    local $_  = shift;
    1 while s/((?:\A|[^.0-9])[-+]?\d+)(\d{3})/$1,$2/s;
    return $_;
}

sub c { CTF4U->context() }
sub uri_with { CTF4U->context()->req->uri_with(@_) }
sub uri_for { CTF4U->context()->uri_for(@_) }

{
    my %static_file_cache;
    sub static_file {
        my $fname = shift;
        my $c = CTF4U->context;
        if (not exists $static_file_cache{$fname}) {
            my $fullpath = File::Spec->catfile($c->base_dir(), $fname);
            $static_file_cache{$fname} = (stat $fullpath)[9];
        }
        return $c->uri_for(
            $fname, {
                't' => $static_file_cache{$fname} || 0
            }
        );
    }
}

1;
