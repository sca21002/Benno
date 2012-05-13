use strict;
use Test::More qw(no_plan); 
use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin, '..', 'lib');

use_ok('UBR::Signatur');

isa_ok(UBR::Signatur->new_from_string('80/VA_0000'),'UBR::Signatur::RVK');

done_testing();