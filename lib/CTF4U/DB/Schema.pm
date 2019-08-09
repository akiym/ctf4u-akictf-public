package CTF4U::DB::Schema;
use v5.24;
use strictures 2;
use Teng::Schema::Declare;
use JSON::XS;

table {
    name 'c4u_user';
    pk 'id';
    columns (
        'id',
        'user_id',
        'screen_name',
        'score',
        'solves',
        'struct',
    );
    inflate struct => sub { decode_json($_[0]) };
    deflate struct => sub { encode_json($_[0]) };
    row_class 'CTF4U::DB::Row::User';
};

table {
    name 'c4u_event';
    pk 'id';
    columns (
        'id',
        'event_source_id',
        'name',
        'year',
        'struct',
    );
    inflate struct => sub { decode_json($_[0]) };
    deflate struct => sub { encode_json($_[0]) };
    row_class 'CTF4U::DB::Row::Event';
};

table {
    name 'c4u_event_source';
    pk 'id';
    columns (
        'id',
        'name',
        'ctf_id',
        'struct',
    );
    inflate struct => sub { decode_json($_[0]) };
    deflate struct => sub { encode_json($_[0]) };
    row_class 'CTF4U::DB::Row::EventSource';
};

table {
    name 'c4u_difficulty';
    pk 'id';
    columns (
        'id',
        'name',
        'point',
    );
    row_class 'CTF4U::DB::Row::Difficulty';
};

table {
    name 'c4u_genre';
    pk 'id';
    columns (
        'id',
        'name',
    );
    row_class 'CTF4U::DB::Row::Genre';
};

table {
    name 'c4u_chall';
    pk 'id';
    columns (
        'id',
        'difficulty_id',
        'genre_id',
        'event_id',
        'name',
        'solves',
        'struct',
    );
    # event_struct
    inflate qr/struct/ => sub { decode_json($_[0]) };
    deflate qr/struct/ => sub { encode_json($_[0]) };
    row_class 'CTF4U::DB::Row::Chall';
};

table {
    name 'c4u_solution';
    pk 'id';
    columns (
        'id',
        'user_id',
        'chall_id',
        'updated_at',
    );
    row_class 'CTF4U::DB::Row::Solution';
};

1;
