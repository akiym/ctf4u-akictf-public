use v5.24;
use strictures 2;
use LWP::UserAgent;
use Path::Tiny;
use Log::Minimal;

use CTF4U;
use CTF4U::Util;
use CTF4U::ChallFinder;
use CTF4U::M::Chall;
use CTF4U::M::Difficulty;

my $c = CTF4U->bootstrap;

# @bata_24 さんのpwn challenges listから問題をインポートする
my $url = 'http://pastebin.com/raw/uyifxgPu';

my $debug = 0;

my $tempfile = '/tmp/pwn-challenges-list';
my $ua = LWP::UserAgent->new();

my $content;
if ($debug && -e $tempfile) {
    $content = path($tempfile)->slurp_utf8;
} else {
    my $res = $ua->get($url);
    croakf($res->status_line) if $res->is_error;
    $content = $res->content;
    path($tempfile)->spew_utf8($content);
}

my %difficulty_names = map {
    ($_->name => $_->id)
} CTF4U::M::Difficulty->all->@*;

my $genre = 'pwn';
my $difficulty;

for my $line (split /\r\n/, $content) {
    if ($line =~ /^(\w[\w\s]+)$/) {
        $difficulty = $1;
    }
    if ($line =~ /^\s*\[(.+?)\]\s*(.+)$/) {
        my ($event_name, $name) = ($1, $2);

        $name =~ s/\s*(?:--.+|\||\+--.+)$//; # fssシリーズのゴミを取り除く
        $name =~ s/^(?:Pwn\s+\d+\s+(?:-\s+)?|Pwn\s+)//;

        $name =~ s/\s+-\s+((?:pwn(?:ables?|ing)?|exploit(?:ation|ing)).+?|\d+|\d+\s*Points)$//i;
        $name =~ s/^((?:pwn(?:ables?|ing)?|exploit(?:ation|ing)).*?|\d+)\s+-\s+//i;
        $name =~ s/\s+-\s+analysis offensive.+//;
        $name =~ s/^(?:Exp|Pwnable)\d+\s+//;
        $name =~ s/\s+pwn\d+$//;

        # defcon
        $name =~ s/(\s+-\s+)?Baby's First:?\s*\d*(\s+-\s+)?//i;
        $name =~ s/^(?:Selir|Lightning):\s*\d*\s+-\s+//i;
        $name =~ s/\s+-\s+There I Fixed It$//i;

        # pwnable.kr
        $name =~ s/(\[.+?\])\s*//;

        # twctf
        $name =~ s!^Web/Pwn/For\s+!!;

        $name =~ s/^#\d+\s*//;
        $name =~ s/^Q\d+\s*-\s*//;

        $event_name =~ s/DEFCON/DEF CON/i;
        $event_name =~ s/gits/Ghost in the Shellcode/i;
        $event_name =~ s/bkp/Boston Key Party/i;
        $event_name =~ s!TWMMA!Tokyo Westerns/MMA!i;
        $event_name =~ s/PHDays/PHD/i;

        # ghost in the shellcode
        if ($name =~ s/Teaser Round #\d\s+-\s+//) {
            $event_name .= ' teaser';
        }

        # defcon
        if ($event_name =~ /DEF CON/ && $event_name !~ /final/i) {
            $event_name .= ' qualifier';
        }

        # 9447
        if ($event_name =~ /9447/) {
            $event_name .= 'Security Society';
        }

        # TMCTF
        if ($event_name =~ /Trend Micro CTF/ && $event_name =~ /2015/) {
            $event_name = 'Trend Micro CTF Asia Pacific & Japan 2015 Online Qualifier';
        }

        my $event = CTF4U::ChallFinder->find_event($event_name);

        my $chall = CTF4U::M::Chall->retrieve_by(
            name     => $name,
            event_id => $event->id,
        );

        if ($chall) {
            unless ($chall->difficulty_id == $difficulty_names{$difficulty}) {
                infof('changed difficulty: %s (%s) %s -> %s',
                    $name, $event->name, $chall->difficulty_id, $difficulty);
                CTF4U::M::Chall->update(
                    id            => $chall->id,
                    difficulty_id => $difficulty_names{$difficulty},
                );
            }
        } else {
            infof('new challenge: %s (%s)', $name, $event->name);
            CTF4U::M::Chall->insert(
                genre      => $genre,
                difficulty => $difficulty,
                event      => $event_name,
                name       => $name,
            );
        }
    }
}

purge_cache 'challenges';
purge_cache 'status';
purge_cache 'options';
