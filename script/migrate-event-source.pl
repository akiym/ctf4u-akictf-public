use v5.24;
use strictures 2;

use CTF4U;
use CTF4U::M::Chall;
use CTF4U::M::Event;

my $c = CTF4U->bootstrap;

# twctf
{
    my $row = $c->db->single('c4u_event', {
        name => 'Tokyo Westerns/MMA CTF 2nd 2016',
    });
    CTF4U::M::Event->update_struct(
        id => $row->id,
        struct => {
            download_link => 'https://github.com/tokyowesterns/twctf-2016-problems',
        },
    );
}

# hack.lu archive
{
    my @rows = $c->db->search_by_sql(
        q{
select *
from c4u_event
where event_source_id =
    (select event_source.id from c4u_event_source as event_source where event_source.name = ?)
    },
        ['Hack.lu CTF'],
        'c4u_event_source'
    );
    for my $row (@rows) {
        # 2016/11/30 school.fluxfingers.net is not available
        # [21:19]     @lucebac | 2015 is (not yet) available
        my $year = $row->year;
        next if $year >= 2015;
        CTF4U::M::Event->update_struct(
            id => $row->id,
            struct => {
                url => "https://ctf.fluxfingers.net/$year",
            },
        );
    }
}


# my @rows = $c->db->search_by_sql(
#     q{
# select *
# from c4u_event as event
#     },
#     [],
#     'c4u_event_source'
# );
# for my $row (@rows) {
#     my $url = $row->struct->{url};
#     if (defined $url) {
#         CTF4U::M::Chall->update_struct(
#             id => $row->id,
#             struct => {
#                 url => $url,
#             },
#         );
#     }
# }
