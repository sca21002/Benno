package UBR::Sisis::Schema::Result::D11rueck;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->table('sisis.d11rueck');
__PACKAGE__->add_columns(
    'd11sig',                          # Signatur
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 40,  },
    'd11mcopyno',                      # Verweis zu Titel   oder PFL-Titeldatei
    {data_type  => 'INTEGER', default_value => undef, is_nullable => 1, },
    'd11tag',                          # Tagesdatum
    {data_type  => 'datetime', default_value => undef, is_nullable => 1, },
    'd11zweig',                        # Zweigstelle
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd11titlecatkey',                  # Verweis zu Titel-Katkey
    {data_type  => 'INTEGER', default_value => undef, is_nullable => 1, },
);

__PACKAGE__->set_primary_key(qw(d11sig d11tag));

__PACKAGE__->belongs_to(
    "d01buch",
    "UBR::Sisis::Schema::Result::D01buch",
    { "foreign.d01ort" => "self.d11sig" }
);

no Moose;
__PACKAGE__->meta->make_immutable;
1;
