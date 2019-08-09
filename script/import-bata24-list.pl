use v5.24;
use strictures 2;
use LWP::UserAgent;

use CTF4U;
use CTF4U::M::Chall;

my $c = CTF4U->bootstrap;

# @bata_24 さんのpwn challenges listから問題をインポートする

my $ua = LWP::UserAgent->new();
my $url = 'http://pastebin.com/raw/uyifxgPu';

unless (-e 'tmp') {

my $res = $ua->get($url);
die $res->status_line if $res->is_error;

open my $fh, '>', 'tmp' or die $!;
print {$fh} $res->content;
close $fh;

}

my $content = do {
    open my $fh, '<', 'tmp' or die $!;
    local $/; <$fh>;
};

my $genre = 'pwn';
my $difficulty;

for my $line (split /\r\n/, $content) {
    if ($line =~ /^(\w[\w\s]+)$/) {
        $difficulty = $1;
    }
    if ($line =~ /^\s*\[(.+?)\]\s*(.+)$/) {
        my ($event, $name) = ($1, $2);

        $name =~ s/\s*(?:--.+|\||\+--.+)$//; # fssシリーズのゴミを取り除く
        $name =~ s/^Pwn\s+//;

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

        $event =~ s/DEFCON/DEF CON/i;
        $event =~ s/gits/Ghost in the Shellcode/i;
        $event =~ s/bkp/Boston Key Party/i;
        $event =~ s!TWMMA!Tokyo Westerns/MMA!i;
        $event =~ s/PHDays/PHD/i;

        # ghost in the shellcode
        if ($name =~ s/Teaser Round #\d\s+-\s+//) {
            $event .= ' teaser';
        }

        # defcon
        if ($event =~ /DEF CON/ && $event !~ /final/i) {
            $event .= ' qualifier';
        }

        CTF4U::M::Chall->insert(
            genre      => $genre,
            difficulty => $difficulty,
            event      => $event,
            name       => $name,
        );
    }
}
