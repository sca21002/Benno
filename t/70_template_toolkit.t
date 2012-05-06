use strict;
use Template::Test;

$Template::Test::DEBUG = 1;   # set this true to see each test running

my $params = { a => 'a', };

my $tt = Template->new();
 
test_expect(\*DATA, $tt, $params);

__END__
# Komentar
-- test --
[% a %]
c: [% 'Hallo' %]
-- expect --
a
c: Hallo
