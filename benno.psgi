use strict;
use warnings;

use Benno;

my $app = Benno->apply_default_middlewares(Benno->psgi_app);
$app;

