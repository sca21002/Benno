use strict;
use Test::More qw(no_plan); 
use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin, '..', 'lib');
use Config::ZOMG;

BEGIN {
    use_ok( 'Benno::Schema' ) or exit;
}

my $config = Config::ZOMG->new(
    name => 'Benno',
    path => File::Spec->catfile($FindBin::Bin,'..'),
);
my $config_hash = $config->load;
my @connect = @{$config_hash->{'Model::BennoDB'}{connect_info}};  

my $schema_atacama = Benno::Schema->connect(
    @{$config_hash->{'Model::BennoDB'}{connect_info}}  
);



                                                      




