use v5.24;
use strictures 2;
use Path::Tiny;

use CTF4U;
use CTF4U::ChallFinder;
use CTF4U::M::Chall;
use CTF4U::M::Event;

my $c = CTF4U->bootstrap;

# write-ups-2014/def-con-ctf-finals-2014 には README.md が存在しない

my %challs;
for my $year (2013..2016) {
    my @events = grep { $_->is_dir && $_->basename ne '.git' }
        path('data', 'write-ups-' . $year)->children;
    for my $event (@events) {
        my $event_name = get_event_name($event);
        if ($event_name) {
            push @{$challs{$year}}, [$event_name, $event];
        }
    }
}

my $challs = CTF4U::M::Chall->all;
for my $chall (@$challs) {
    my $event = CTF4U::M::Event->retrieve_by_id($chall->event_id);
    my $event_name = $event->name;
    say $chall->name . ": $event_name (" . ($event->year // '') . ')';
    if ($event->year && $event->year >= 2014) {
        my %score;
        for my $name (map { $_->[0] } $challs{$event->year}->@*) {
            $score{$name} = Text::Dice::coefficient($event_name, $name);
        }
        my $event_dir = (map { $_->[1] } sort { $score{$b->[0]} <=> $score{$a->[0]} } $challs{$event->year}->@*)[0];
        $event_dir
    }
    say '';
    #CTF4U::ChallFinder->find_event();
}

sub get_event_name {
    my $path = shift;
    my $readme = $path->child('README.md');
    return unless $readme->exists;
    my $src = $readme->slurp;
    my ($name) = $src =~ /\A#\s*(.+)$/m or return;
    $name =~ s/\s*write-ups$//i;
    return $name;
}
