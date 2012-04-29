package Benno::Model::SisisDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'UBR::Sisis::Schema',
);

=head1 NAME

Benno::Model::SisisDB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<Benno>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<UBR::Sisis::Schema>

=head1 AUTHOR

Benno Developer

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
