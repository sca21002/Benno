use strict;

use warnings;
use Data::Dumper;
use feature ('say');

sub foo {
return (hallo => 'ich bins');
}

sub bar {
return;
}

my %hash = (foo(),bar());
say Dumper(\%hash);

say %hash ? 'true' : 'false';