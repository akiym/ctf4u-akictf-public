use v5.24;
use strictures 2;
use Path::Tiny;
use Log::Minimal;

use CTF4U;
use CTF4U::Util;
use CTF4U::M::Chall;

my $c = CTF4U->bootstrap;

update_download_link_by_chall_and_event_name(
    'fss_montgomery', 'Boston Key Party CTF 2013',
    'https://github.com/hellok/CTF/tree/master/pwn/linux/fss_montgomery/problem'
);
update_download_link_by_chall_and_event_name(
    'fss_miami', 'Boston Key Party CTF 2013',
    '/ctf4u/static/challenge/fss_miami.zip'
);
update_download_link_by_chall_and_event_name(
    'fss_bridgeport', 'Boston Key Party CTF 2013',
    '/ctf4u/static/challenge/fss_bridgeport.zip'
);

update_download_link_by_chall_and_event_name(
    'secure_mm', 'Trend Micro CTF Asia Pacific & Japan 2015 Online Qualifier',
    '/ctf4u/static/challenge/secure_mm'
);

update_download_link_by_chall_and_event_name(
    'e1000', 'PlaidCTF 2013',
    'https://captf.com/2013/pctf'
);

update_download_link_by_chall_and_event_name(
    'Web servr', 'PlaidCTF 2013',
    'https://captf.com/2013/pctf'
);

update_source(
    'classy', 'PHD CTF Quals 2014',
    '9447 Security Society CTF 2014',
);

update_source(
    'Choose your Pwn Adventure', 'Ghost in the Shellcode Teaser 2014',
    'Ghost in the Shellcode 2013',
);

purge_cache 'challenges';
purge_cache 'options';

#update_source(
#'Choose your Pwn Adventure',
#'Ghost in the Shellcode Teaser 2014'
#);
#'Ghost in the Shellcode Teaser 2013'
#'http://ghostintheshellcode.com/2013-teaser/'

sub update_download_link_by_chall_and_event_name {
    my ($chall_name, $event_name, $url) = @_;
    my $chall = $c->db->single_by_sql(
        q{
select chall.*
from c4u_chall as chall
    inner join c4u_event as event on chall.event_id = event.id
where chall.name = ? and event.name = ?
    },
        [$chall_name, $event_name],
        'c4u_chall'
    );
    if ($chall) {
        CTF4U::M::Chall->update_struct(
            id     => $chall->id,
            struct => {
                download_link => $url,
            },
        );
        infof("%s (%s) download_link was updated: %s --> %s", $chall_name, $event_name, $chall->struct->{download_link}, $url);
    } else {
        errorf('no such chall: %s (%s)', $chall_name, $event_name);
    }
}

sub update_source {
    my ($chall_name, $old, $new) = @_;
    my $chall = $c->db->single_by_sql(
        q{
select chall.*
from c4u_chall as chall
    inner join c4u_event as event on chall.event_id = event.id
where chall.name = ? and event.name = ?
    },
        [$chall_name, $old],
        'c4u_chall'
    ) or return;
    my $old_event = $c->db->single('c4u_event', {name => $old})
        or croakf('no such event: %s', $old);
    my $new_event = $c->db->single('c4u_event', {name => $new})
        or croakf('no such event: %s', $new);

    my $txn = $c->db->txn_scope;
    $chall->update({
        event_id => $new_event->id,
    });
    infof("%s (%s) event_id was updated: %s",
        $chall_name, $old_event->name, $new_event->name);
    $txn->commit;
}
