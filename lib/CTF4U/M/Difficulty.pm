package CTF4U::M::Difficulty;
use v5.24;
use strictures 2;
use Amon2::Declare;
use Data::Validator;

sub retrieve_by_name {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        name => 'Str',
    )->with('StrictSequenced');
    my $args = $rule->validate(@_);

    return $c->db->single('c4u_difficulty', {name => $args->{name}});
}

sub all {
    my $class = shift;
    my $c = c();

    return [$c->db->search('c4u_difficulty' => {}, {order_by => 'point'})];
}

1;
