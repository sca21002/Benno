package Benno::Controller::Label;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Benno::Controller::Label - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Benno::Controller::Label in Label.');
}

sub labels : Chained('/base') PathPart('etikett') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{labels} = $c->model('BennoDB::Labels');
}

sub labels_type : Chained('labels') PathPart('') CaptureArgs(1) {
    my ( $self, $c ) = @_;    
}

sub list : Chained('labels_type') PathPart('list') Args(0) {
    my ( $self, $c ) = @_;
}

=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
