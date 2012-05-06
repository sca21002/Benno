use utf8;
package Benno::Schema::Result::Client;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Benno::Schema::Result::Client

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

=head1 TABLE: C<clients>

=cut

__PACKAGE__->table("clients");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 address

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 hostname

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 room

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 active

  data_type: 'integer'
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
  "address",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "hostname",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "room",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "active",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<address>

=over 4

=item * L</address>

=back

=cut

__PACKAGE__->add_unique_constraint("address", ["address"]);

=head2 C<hostname>

=over 4

=item * L</hostname>

=back

=cut

__PACKAGE__->add_unique_constraint("hostname", ["hostname"]);


# Created by DBIx::Class::Schema::Loader v0.07023 @ 2012-05-05 16:18:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:irt5Pm27RZn5h3l75zz+IA


__PACKAGE__->has_many(
    "clients_roles",
    "Benno::Schema::Result::ClientRole",
    { "foreign.client_id" => "self.id" }
);

__PACKAGE__->many_to_many("roles", "clients_roles", "role");

__PACKAGE__->meta->make_immutable;
1;
