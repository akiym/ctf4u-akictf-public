use v5.24;
use strictures 2;

use CTF4U;
use CTF4U::CTFtimeAPI;
use CTF4U::M::Event;

my $c = CTF4U->bootstrap;

my $ctfs = CTF4U::CTFtimeAPI->information_about_ctfs();
for my $ctf (@$ctfs) {
    CTF4U::M::Event->insert_source_from_ctftime($ctf);
}

my $events = CTF4U::CTFtimeAPI->events_information(
    limit => 10000,
    start => 0,
);
for my $event (@$events) {
    CTF4U::M::Event->insert_from_ctftime($event);
}
