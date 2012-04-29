package Benno::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Benno::Controller::Root - Root Controller for Benno

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 home

The root page (/)

=cut

sub base : Chained('/login/required') PathPart('') CaptureArgs(0) {}
 
sub home : Chained('/base') PathPart('') Args(0) {
    my ($self, $c) = @_;
 
    $c->res->redirect($c->uri_for('/label/list'));
}
 

=head2 default

Standard 404 error page

=cut

sub default : Chained('/base') PathPart('') Args {
    my ($self, $c) = @_;
    $c->res->body('Page not found');
    $c->res->status(404);
}
 
=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
