use Path::Tiny;
my $base_dir = path(__FILE__)->parent->parent;
+{
    'DBI' => [
        'dbi:mysql:akictf', 'akictf', '',
        +{
            mysql_enable_utf8 => 1,
        }
    ],
    'Text::Xslate' => {
        cache_dir => $base_dir->child('tmp', 'xslate_cache')->realpath->stringify,
    },
    'Cache::FileCache' => {
        cache_root => $base_dir->child('tmp')->realpath->stringify,
        namespace  => 'cache.vAA15CiF',
    },
    'ServerStatus::Lite' => {
        path         => '/server-status',
        allow        => ['127.0.0.1'],
        counter_file => $base_dir->child('run', 'counter')->stringify,
        scoreboard   => $base_dir->child('run', 'server')->stringify,
    },

    'akictf' => {
        internal => 'http://akictf.test/api/internal/',
    },
};
