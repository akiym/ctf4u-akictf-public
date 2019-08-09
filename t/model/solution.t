use t::Test;

use CTF4U::Test::User;
use CTF4U::M::Solution;

subtest 'update' => sub {
    my $user = create_user;
    is $user->solves, 0;

    CTF4U::M::Solution->update(
        user_id  => $user->id,
        chall_id => 1,
        solved   => 1,
    );

    my $solution = CTF4U::M::Solution->retrieve(
        user_id  => $user->id,
        chall_id => 1,
    );
    isa_ok $solution, 'CTF4U::DB::Row::Solution';
    is $solution, object {
        call user_id  => $user->id;
        call chall_id => 1;
        call updated_at => '0000-00-00 00:00:00';
    };

    $user = $user->refetch;
    is $user->solves, 1;
};

done_testing;
