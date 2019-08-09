package CTF4U::Types;
use v5.24;
use strictures 2;
use Module::Find;
use Mouse::Util::TypeConstraints;

subtype Id => as 'Str' => where { /^[0-9]+$/ };

my $base = 'CTF4U::DB::Row';
for my $class (findsubmod($base)) {
    (my $type = $class) =~ s/^$base\:://;
    subtype $type => as $class;
}

no Mouse::Util::TypeConstraints;

1;
