package CTF4U::Test::DB;
use v5.24;
use strictures 2;

use DBI;
use Path::Tiny;

sub my_cnf {
    +{
        'skip-networking'      => '',
        'character-set-server' => 'utf8mb4',
    };
}

sub prepare {
    my ($class, $mysqld) = @_;

    my $dbh = DBI->connect($mysqld->dsn);

    my @sqls = qw(
        sql/mysql.sql
        sql/migrate.sql
        sql/20161204-hitcon.sql
    );
    for my $sql (map { path($_) } @sqls) {
        say "preparing $sql";
        $dbh->do($_) for grep { $_ ne '' } ($sql =~ /(.*?[^\\]);/g), $`;
    }
}

1;
