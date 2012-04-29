use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Benno';
use Benno::Controller::Label;

ok( request('/label')->is_success, 'Request should succeed' );
done_testing();
