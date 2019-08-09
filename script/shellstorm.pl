use v5.24;
use strictures 2;
use Path::Tiny;

use CTF4U;
use CTF4U::M::Chall;

my $c = CTF4U->bootstrap;

my $shellstorm_dir = path('/Users/akiym/ctf/ctfs/shell-storm/pages');

my @rows = $c->db->search_by_sql(
    q{
select
    chall.*
    , event.name as event_name
    , event.year
    , event.struct as event_struct
from c4u_chall as chall
    inner join c4u_event as event on chall.event_id = event.id
    },
    [],
    'c4u_chall'
);
for my $row (@rows) {
    my $name = $row->name;
    my $event_name = $row->event_name;
    (my $name_simple = $name) =~ s/[^A-Za-z0-9]//g;
    (my $name_sep = $name) =~ s/[-_\s]+/[-_\\s]+/;
    my $pat = qr/(\Q$name\E|$name_sep|$name_simple)/i;
    my $has_struct = %{$row->struct} || $row->event_struct->{url};
    unless ($has_struct) {
        my @found;
        $shellstorm_dir->visit(sub {
            my ($path, $state) = @_;
            my $src = $path->slurp_raw;
            if ($src =~ $pat) {
                push @found, $path;
            }
        }, {recurse => 1});
        if (@found) {
            if (@found == 1) {
                my $url_path = $found[0];
                $url_path =~ s!.+pages/!!;
                $url_path =~ s!--!/!g;
                CTF4U::M::Chall->update_struct(
                    id     => $row->id,
                    struct => {
                        download_link => "http://shell-storm.org/repo/CTF$url_path",
                    },
                );
            } else {
                #warn "multiple $name $event_name";
            }
        } else {
            warn "$name $event_name";
        }
    }
}

update_download_link_by_event_name(
    'CSAW CTF Qualification Round 2013',
    'http://shell-storm.org/repo/CTF/CSAW-2013/Exploitation/'
);
update_download_link_by_event_name(
    'CSAW CTF Qualification Round 2012',
    'http://shell-storm.org/repo/CTF/CSAW-2012/Exploitation/'
);
update_download_link_by_event_name(
    'Codegate CTF Preliminary 2013',
    'http://shell-storm.org/repo/CTF/CodeGate-2013/Vulnerable/'
);

update_download_link_by_event_name(
    'Ghost in the Shellcode 2013',
    'http://shell-storm.org/repo/CTF/GITS-2013/Pwnable/'
);
update_download_link_by_event_name(
    'SIGINT CTF 2013',
    'http://shell-storm.org/repo/CTF/SIGINT-2013/pwning/'
);
update_download_link_by_event_name(
    '29c3 CTF',
    'http://shell-storm.org/repo/CTF/29c3/Exploitation/'
);
update_download_link_by_event_name(
    'DEF CON CTF 2014',
    'http://shell-storm.org/repo/CTF/Defcon-22-finals/'
);

update_download_link_by_event_name(
    '30C3 CTF',
    'https://archive.aachen.ccc.de/30c3ctf.aachen.ccc.de/challenges/'
);
update_download_link_by_event_name(
    'UFO CTF 2013',
    'https://github.com/PHX2600/ufoctf-2013'
);
update_download_link_by_event_name(
    'Ghost in the Shellcode Teaser 2014',
    'http://ghostintheshellcode.com/2014-teaser/'
);
update_download_link_by_event_name(
    'DEF CON CTF Qualifier 2016',
    'https://github.com/legitbs/quals-2016'
);

update_download_link_by_chall_and_event_name(
    'pwn200', 'EBCTF 2013',
    'http://shell-storm.org/repo/CTF/EbCTF-2013-08/Pwnables/'
);
update_download_link_by_chall_and_event_name(
    'PWN200', 'PHD CTF Quals 2012',
    'http://shell-storm.org/repo/CTF/PHDays-Quals-2012/PWN/'
);

update_download_link_by_chall_and_event_name(
    'ropasaurusrex', 'PlaidCTF 2013',
    'http://shell-storm.org/repo/CTF/PlaidCTF-2013/Pwnable/'
);

update_download_link_by_chall_and_event_name(
    'knurd', 'BCTF 2016',
    '/ctf4u/static/challenge/knurd'
);
update_download_link_by_chall_and_event_name(
    'fss_rancho', 'Boston Key Party CTF 2013',
    '/ctf4u/static/challenge/fss_rancho'
);
update_download_link_by_chall_and_event_name(
    'fss_burlington', 'Boston Key Party CTF 2013',
    '/ctf4u/static/challenge/fss_burlington'
);
update_download_link_by_chall_and_event_name(
    'fss_gainesville', 'Boston Key Party CTF 2013',
    '/ctf4u/static/challenge/fss_gainesville'
);

sub update_download_link_by_event_name {
    my ($event_name, $url) = @_;
    my @rows = $c->db->search_by_sql(
        q{
select chall.*
from c4u_chall as chall
where event_id =
    (select event.id from c4u_event as event where event.name = ?)
    },
        [$event_name],
        'c4u_chall'
    );
    for my $row (@rows) {
        CTF4U::M::Chall->update_struct(
            id     => $row->id,
            struct => {
                download_link => $url,
            },
        );
    }
}

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
    }
}
