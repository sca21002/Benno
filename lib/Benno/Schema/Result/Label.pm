use utf8;
package Benno::Schema::Result::Label;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Benno::Schema::Result::Label

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

=head1 TABLE: C<labels>

=cut

__PACKAGE__->table("labels");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 d11sig

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 40

=head2 d11mcopyno

  data_type: 'integer'
  is_nullable: 1

=head2 d11tag

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=head2 d11zweig

  data_type: 'smallint'
  is_nullable: 1

=head2 d11titlecatkey

  data_type: 'integer'
  is_nullable: 1

=head2 d01gsi

  data_type: 'varchar'
  is_nullable: 1
  size: 27

=head2 d01entl

  data_type: 'varchar'
  is_nullable: 1
  size: 1

=head2 d01mtyp

  data_type: 'smallint'
  is_nullable: 1

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 5

=head2 printed

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 deleted

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
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
  "d11sig",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 40 },
  "d11mcopyno",
  { data_type => "integer", is_nullable => 1 },
  "d11tag",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
  "d11zweig",
  { data_type => "smallint", is_nullable => 1 },
  "d11titlecatkey",
  { data_type => "integer", is_nullable => 1 },
  "d01gsi",
  { data_type => "varchar", is_nullable => 1, size => 27 },
  "d01entl",
  { data_type => "varchar", is_nullable => 1, size => 1 },
  "d01mtyp",
  { data_type => "smallint", is_nullable => 1 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 5 },
  "printed",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "deleted",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<d11sig>

=over 4

=item * L</d11sig>

=item * L</d11tag>

=back

=cut

__PACKAGE__->add_unique_constraint("d11sig", ["d11sig", "d11tag"]);


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2012-05-01 11:43:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oX43c/CzihQgvcpMwn4E6w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
