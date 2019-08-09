package CTF4U::ChallFinder;
use v5.24;
use strictures 2;
use Amon2::Declare;
use Data::Validator;
use Text::Dice;

use CTF4U::GitRepos;
use CTF4U::M::Event;

sub find_event {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        event_name => 'Str',
    )->with('StrictSequenced');
    my $args = $rule->validate(@_);

    my ($year) = $args->{event_name} =~ /(20\d{2})/;
    my @events;
    for my $event (CTF4U::M::Event->all->@*) {
        my $name = $event->name;
        if ($name =~ /DEF CON/) {
        } else {
            $name =~ s/\s*(?:qual(?:ifier|ification|s)?|preliminary)//i;
        }
        push @events, {
            id   => $event->id,
            name => $name,
            year => $event->year,
        };
    }
    my %score;
    for my $event (@events) {
        my $name = $event->{name};
        $score{$name} = Text::Dice::coefficient($args->{event_name}, $name);
        if ($year && $year != $event->{year}) {
            $score{$name} -= 500;
        }
    }
    my $event = (sort { $score{$b->{name}} <=> $score{$a->{name}} } @events)[0];
    return CTF4U::M::Event->retrieve_by_id($event->{id});
}

sub find_link {
    my $class = shift;
}

1;
