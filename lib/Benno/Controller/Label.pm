package Benno::Controller::Label;
use Moose;
use namespace::autoclean;

use Data::Dumper;

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

    $c->stash->{labels} = $c->model('BennoDB::Label');
}

sub labels_type : Chained('labels') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $label_group ) = @_;

    $type |= 'alle';
    my $label_rs = $c->stash->{labels};
    $c->stash->{labels} = $label_rs->filter_label_group($label_group);
}
 

sub list : Chained('labels_type') PathPart('list') Args(0) {
    my ( $self, $c ) = @_;
    
    $c->log->debug('URI for action: ' . $c->uri_for_action('/label/json',  $c->req->captures));
    $c->stash(
	json_url => $c->uri_for_action('/label/json', $c->req->captures)
    );
}

sub print :  Chained('labels_type') PathPart('print') Args(0) {
    my ( $self, $c ) = @_;

}


sub json : Chained('labels_type') PathPart('json') Args(0) {
	my ( $self, $c ) = @_;

	my $data = $c->req->params;
	$c->log->debug( Dumper($data) );

	my $page             = $data->{page} || 1;
	my $entries_per_page = $data->{rows} || 25;
	my $sidx             = $data->{sidx} || 'd11sig';
	my $sord             = $data->{sord} || 'asc';

	my $search =
	     $data->{searchField}
	  && $data->{searchString}
	  ? { $data->{searchField} => $data->{searchString} }
	  : {};
	# $search->{gedruckt} = undef;
	# $search->{typ}      = 'weiss';

	my $label_rs = $c->stash->{labels};

	$label_rs = $label_rs->search(
		$search,
		{
			page     => $page,
			rows     => $entries_per_page,
			order_by => "$sidx $sord",
		}
	);

	my $response;
	$response->{page}    = $page;
	$response->{total}   = $label_rs->pager->last_page;
	$response->{records} = $label_rs->pager->total_entries;
	my @rows;
	while ( my $label = $label_rs->next ) {
		my $row->{id} = $label->id;
		$row->{cell} = [
			$label->d11sig,
			$label->d11tag->set_time_zone('Europe/Berlin')
			  ->strftime('%d.%m.%Y'),
			$label->d11zweig,
			$label->d01entl,
		];
		push @rows, $row;
	}
	$response->{rows} = \@rows;

	$c->stash( %$response, current_view => 'JSON' );
}

sub ajax : Chained('labels') {
	my ( $self, $c ) = @_;
	my $data = $c->req->params;
	$c->log->debug( Dumper($data) );

	my $oper = $data->{oper};

	#if ( $oper eq "del" ) {
	#	$c->forward('delete');
	#}

	#if ( $oper eq "print" ) {
	#	$c->forward('print_selected');
	#}
}



=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
