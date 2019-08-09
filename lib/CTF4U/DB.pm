package CTF4U::DB;
use v5.24;
use strictures 2;
use parent qw/Teng/;

__PACKAGE__->load_plugin('Count');
__PACKAGE__->load_plugin('Replace');
__PACKAGE__->load_plugin('Pager');

1;
