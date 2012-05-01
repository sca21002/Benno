use utf8;
package Benno::Schema::Result::Labelgroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Benno::Schema::Result::Labelgroup

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<labelgroups>

=cut

__PACKAGE__->table("labelgroups");

=head1 ACCESSORS

=head2 id

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 50

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 search

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "search",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name", ["name"]);


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2012-05-01 11:43:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BkXheeBDwW7BMU3697NbjA


use JSON;

__PACKAGE__->inflate_column('search', {
    inflate => sub { decode_json shift },
    deflate => sub { encode_json shift },
});

__PACKAGE__->meta->make_immutable;
1;