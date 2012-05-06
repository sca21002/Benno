use utf8;
package Benno::Schema::Result::ClientRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Benno::Schema::Result::ClientRole

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

=head1 TABLE: C<clients_roles>

=cut

__PACKAGE__->table("clients_roles");

=head1 ACCESSORS

=head2 client_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 role_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "client_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "role_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</client_id>

=item * L</role_id>

=back

=cut

__PACKAGE__->set_primary_key("client_id", "role_id");


# Created by DBIx::Class::Schema::Loader v0.07023 @ 2012-05-05 16:18:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6E8lZhk4jLF/a58iYS+uKg


__PACKAGE__->belongs_to(
    "role",
    "Benno::Schema::Result::Role",
    { "foreign.id" => "self.role_id" }
);

__PACKAGE__->meta->make_immutable;
1;
