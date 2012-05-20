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

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "PassphraseColumn");

=head1 TABLE: C<labelgroups>

=cut

__PACKAGE__->table("labelgroups");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 urlname

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 shortname

  data_type: 'varchar'
  is_nullable: 1
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
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "urlname",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "shortname",
  { data_type => "varchar", is_nullable => 1, size => 50 },
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

=head2 C<shortname>

=over 4

=item * L</shortname>

=back

=cut

__PACKAGE__->add_unique_constraint("shortname", ["shortname"]);

=head2 C<urlname>

=over 4

=item * L</urlname>

=back

=cut

__PACKAGE__->add_unique_constraint("urlname", ["urlname"]);


# Created by DBIx::Class::Schema::Loader v0.07023 @ 2012-05-17 13:42:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:p/Bm/o/cXlp08ulO/Sg8Tw


use JSON;

__PACKAGE__->inflate_column('search', {
    inflate => sub { decode_json shift },
    deflate => sub { encode_json shift },
});

__PACKAGE__->meta->make_immutable;
1;
