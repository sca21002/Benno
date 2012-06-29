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
        {
            urlname     => 'alle',
            shortname   => 'Alle',
            name => 'Alle',
            search => {},
        },
        {
            urlname     => 'rw',
            shortname => 'R & W', 
            name => 'Recht & Wirtschaft',
            search => {
                d11sig =>  { '>' => '30/', '<' => '50/' },
                type   =>  'weiss',              
            }
        },
        {
            urlname     => 'pt',
            shortname => 'PT',
            name => 'PT',
            search => {
                d11sig => [
                    { '>' => '151/', '<' => '16/'},
                    { '>' => '160/', '<' => '163/'},
                    {'-like' => '180/%'},
                    { '>' => '50/', '<' => '80/' },
                ],
                type   => 'weiss',                  
            },
        },
        #{
        #    urlname     => 'alle',
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
            urlname     => 'zb_weiss',
            shortname => 'ZB Weiß',
            name => 'ZB Weiß',
            search => {
                d11sig => [
                    -or =>
                    { '<' => '151/' },
                    { '>' => '16/', '<' => '160/' },
                    { '>' => '163/', '<' => '180/' },
                    { '>' => '181/', '<' => '50/' },
                    { '>' => '80/',  '<' => '9996/', },
                    { '>' => '9997/', '<' => '9998/' },
                    { '>' => '9999/' }
                ],
                type   => 'weiss',
            },      
                      
        },
        {
            urlname     => 'zb_rot',
            shortname => 'ZB Rot',
            name => 'ZB Rot',
            search => { type => 'rot' },
        },
        {
            urlname     => 'bma',
            shortname => 'BMA',
            name => 'Bayerische Musikakademie Alteglofsheim',
            search => {
                d11sig => { like => '9996/%' }
            },
        },        
        {
            urlname     => 'ama',
            shortname => 'AMA',
            name => 'Stadtmuseum Abensberg',
            search => {
                d11sig => { like => '9998/%' }
            },
        },
        {
            urlname     => 'msr',
            shortname => 'MSR',
            name => 'Museum der Stadt Regensburg',
            search => { type => 'msr' },
        },        
    ]
);
