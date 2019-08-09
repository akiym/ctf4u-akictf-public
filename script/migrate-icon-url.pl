use v5.24;
use strictures 2;
use Log::Minimal;

use CTF4U;
use CTF4U::M::User;

my $c = CTF4U->bootstrap;

my $txn = $c->db->txn_scope;
my @users = $c->db->search_by_sql(
    q{
select
    user.*,
    akictf.icon_url as akictf_icon_url
from c4u_user as user
    inner join user as akictf on user.user_id = akictf.user_id
    },
    [],
    'c4u_user'
);
for my $user (@users) {
    unless (defined $user->icon_url) {
        infof('update icon_url: %s', $user->screen_name);
        $user->update({icon_url => $user->akictf_icon_url});
    }
}
$txn->commit;
