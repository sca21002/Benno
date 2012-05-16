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
        {   shortname   => 'alle',
            name => 'Alle',
            search => {},
        },
        {
            shortname => 'rw', 
            name => 'Wirtschaft & Recht',
            search => {
                d11sig =>  { '>' => '30/', '<' => '50/' },
                type   =>  'weiss',              
            }
        },
        {
            shortname => 'pt',
            name => 'PT',
            search => {
                d11sig => [
                    { '>' => '50/', '<' => '80/' },
                    { '>' => '151/', '<' => '163/'}, 
                    {'-like' => '180/%'}
                ],
                type   => 'weiss',                  
            },
        },
        #{
        #    shortname => 'med',
        #    name => 'Medizin',
        #    search => {
        #        d11sig => [
        #            { '>=' => '91/', '<' => '99/' },
        #            { '>=' => '910/', '<' => '990/' },
        #            { '>=' => '9100/', '<' => '9900/' },                    
        #        ],
        #        type   => 'weiss',                
        #    },
        #},
        {
            shortname => 'zb_weiss',
            name => 'ZB weiß',
            search => {
                d11sig => [
                    -or => 
                    {'<' => '30/'},
                    {'>' => '80/', '<' => '151/'},
                    [ -and => {'>' => '163/'},
                              {'not_like' => '180/%'},
                              {'not_like' => '9996/%'},
                              {'not_like' => '9998/%'},
                
                    ],
                ],
                type   => 'weiss',
            },      
                      
        },
        {
            shortname => 'zb_rot',
            name => 'ZB rot',
            search => { type => 'rot' },
        },
        {
            shortname => 'bma',
            name => 'Bayerische Musikakademie Alteglofsheim',
            search => {
                d11sig => { like => '9996/%' }
            },
        },        
        {
            shortname => 'ama',
            name => 'Stadtmuseum Abensberg',
            search => {
                d11sig => { like => '9998/%' }
            },
        },
        {
            shortname => 'msr',
            name => 'Museum der Stadt Regensburg',
            search => { type => 'msr' },
        },        
    ]
);
