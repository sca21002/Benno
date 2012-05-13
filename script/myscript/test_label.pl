use strict;
use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin, '..', '..', 'lib');

use UBR::Signatur;

my $label = UBR::Signatur->new_from_string('80/VA 0000');
print 'Valid: ' . $label->is_valid;