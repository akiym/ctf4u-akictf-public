use v5.24;
use strictures 2;
use Path::Tiny;
use Log::Minimal;

use CTF4U;
use CTF4U::Util;
use CTF4U::M::Event;

my $c = CTF4U->bootstrap;

update_event(
    'Ghost in the Shellcode Teaser 2015', {
        year => 2015,
    }
);

purge_cache 'challenges';

sub update_event {
    my ($event_name, $args) = @_;
    my $event = $c->db->single('c4u_event', {
        name => $event_name,
    }) or croakf('missing event %s', $event_name);
    infof('fix event: %s', $event_name);
    $event->update($args);
}
