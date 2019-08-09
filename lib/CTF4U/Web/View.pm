package CTF4U::Web::View;
use v5.24;
use strictures 2;
use Carp ();
use File::Spec ();

use File::ShareDir;
use Text::Xslate 1.6001;
use CTF4U::Web::ViewFunctions;

# setup view class
sub make_instance {
    my ($class, $context) = @_;
    Carp::croak("Usage: CTF4U::Web::View->make_instance(\$context_class)") if @_!=2;

    my $view_conf = $context->config->{'Text::Xslate'} || +{};
    unless (exists $view_conf->{path}) {
        my $tmpl_path = File::Spec->catdir($context->base_dir(), 'tmpl');
        if ( -d $tmpl_path ) {
            # tmpl
            $view_conf->{path} = [ $tmpl_path ];
        } else {
            my $share_tmpl_path = eval { File::Spec->catdir(File::ShareDir::dist_dir('CTF4U'), 'tmpl') };
            if ($share_tmpl_path) {
                # This application was installed to system.
                $view_conf->{path} = [ $share_tmpl_path ];
            } else {
                Carp::croak("Can't find template directory. tmpl Is not available.");
            }
        }
    }
    my $view = Text::Xslate->new(+{
        'syntax'   => 'Kolon',
        'module'   => [
            'Text::Xslate::Bridge::Star',
            'CTF4U::Web::ViewFunctions',
        ],
        'function' => {
        },
        ($context->debug_mode ? ( warn_handler => sub {
            Text::Xslate->print( # print method escape html automatically
                '[[', @_, ']]',
            );
        } ) : () ),
        %$view_conf
    });
    return $view;
}

1;
