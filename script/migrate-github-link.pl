use v5.24;
use strictures 2;
use Path::Tiny;

use CTF4U;
use CTF4U::M::Chall;
use DBIx::QueryLog;

$DBIx::QueryLog::OUTPUT = sub {
    my (%params) = @_;
    my $sql = $params{sql};
    if ($sql !~ /^\s*SELECT/i) {
        say "$sql;";
    }
};

my $c = CTF4U->bootstrap;

my $ctfs_dir = path('/Users/akiym/ctf/ctfs');

my @rows = $c->db->search_by_sql(
    q{
select
    chall.*
    , event.year
    , event.struct as event_struct
from c4u_chall as chall
    inner join c4u_event as event on chall.event_id = event.id
    },
    [],
    'c4u_chall'
);

for my $row (@rows) {
    next if defined $row->struct->{github_link};
    next if $row->event_struct->{dont_spoil}; # 常設CTFは無視
    my $dirname = 'write-ups-' . $row->year;
    my $dir = $ctfs_dir->child($dirname);
    if ($dir->exists) {
        my $name = $row->name;
        (my $name_simple = $name) =~ s/[^A-Za-z0-9]//g;
        #say "searching '$name' in $dir";
        (my $name_sep = $name) =~ s/[-_\s]+/[-_\\s]+/g;
        my $pat = qr/(\Q$name\E|$name_sep|$name_simple)/i;
        my @found;
        $dir->visit(sub {
            my ($path, $state) = @_;
            return unless $path =~ m!/README\.md$!;
            my $src = $path->slurp_raw;
            if ($src =~ $pat) {
                if ($path->parent->parent ne $dir) {
                    push @found, $path;
                }
            }
        }, {recurse => 1});
        if (@found) {
            my %weight;
            if (@found > 1) {
                for my $file (@found) {
                    my $word_count = $file->slurp_raw =~ /$pat/g;
                    my $in_file = $file =~ /$pat/g;
                    $weight{$file} += $word_count + $in_file;
                }
            }
            my $url_path = (sort { $weight{$b} <=> $weight{$a} } @found)[0];
            $url_path =~ s/^.+?$dirname//;
            my $url = "https://github.com/ctfs/$dirname/tree/master$url_path";
            #say "---> $name $url_path";
            CTF4U::M::Chall->update_struct(
                id     => $row->id,
                struct => {
                    github_link => $url,
                },
            );
        } else {
            #say "===> $name";
        }
    }
}
