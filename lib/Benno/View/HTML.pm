package Benno::View::HTML;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    INCLUDE_PATH => [
        Benno->path_to( 'root', 'base' ),
    ],
    render_die => 1,
    ENCODING     => 'utf-8',
    WRAPPER            => 'site/wrapper.tt',   
);

=head1 NAME

Benno::View::HTML - TT View for Benno

=head1 DESCRIPTION

TT View for Benno.

=head1 SEE ALSO

L<Benno>

=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
