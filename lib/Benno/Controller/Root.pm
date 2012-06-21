package Benno::Controller::Root;
use Moose;
use namespace::autoclean;
use List::Util qw(first);

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


sub base : Chained('/') PathPart('') CaptureArgs(0) {
    my ($self, $c) = @_;

    unless ($c->req->address =~ /^132.199.14[456]/) { $c->res->redirect($c->uri_for_action( '/login/login' ) );}
    my @roles = ( $c->model('BennoDB::Client')->roles($c->req->address) );
    push @roles, $c->user->roles if $c->user;  
    
    my $search = first {'admin'} @roles ? {} : {shortname => {'!=' => 'alle'}} ;
    
    $c->stash(
        roles       => [ @roles ],
        labelgroups => [$c->model('BennoDB::Labelgroup')->search($search)->all],
        can_print   => (first { 'admin'|'print' } @roles),
        rows_per_page => $c->session->{rows_per_page} || 20,
        labelgroup => $c->session->{labelgroup}, 
    );    
}
 
sub index : Chained('/base') PathPart('index') Args(0) {}  
 
sub home : Chained('/base') PathPart('') Args {
    my ($self, $c) = @_;
        
    my $lg = $c->session->{labelgroup} &&  $c->session->{labelgroup}->urlname;
    if ( $lg ) {
        $c->res->redirect( $c->uri_for_action( '/label/list', [$lg] ) );
    } else {
        $c->res->redirect( $c->uri_for_action( '/index' ) );
    }
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
