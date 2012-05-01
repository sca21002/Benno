#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Config::ZOMG;
use feature qw(say);
use Benno::Schema;
use Data::Dumper;

my $config = Config::ZOMG->new(
    name => 'Benno',
    path => File::Spec->catfile($FindBin::Bin,'..','..'),
);
my $config_hash = $config->load;
my $schema_benno = Benno::Schema->connect(
    @{$config_hash->{'Model::BennoDB'}{connect_info}}
);
$schema_benno->resultset('Labelgroup')->delete();
my @labelgroups = $schema_benno->resultset('Labelgroup')->populate(
    [
        {   id   => 'alle',
            name => 'Alle',
            search => {},
        },
        {
            id => 'rw', 
            name => 'Wirtschaft & Recht',
            search => { d11sig =>  { '>=' => '30/', '<' => '50/' }  }
        },
        {
            id => 'pt',
            name => 'PT',
            search => {
                d11sig => [
                    { '>=' => '50/', '<' => '80/' }, 
                    {'-like', '180/%'}
                ]
            },
        },
        {
            id => 'med',
            name => 'Medizin',
            search => { d11sig => { '>=' => '91/', '<' => '9999/' } },
        },               
    
    ]
);
