package Benno::Controller::Label;
use Moose;
use namespace::autoclean;
use Benno::UI::ViewPort::Field::Signatur;
use Benno::Form::Label;
use DateTime;
use JSON;
use List::Util qw(first);
use Data::Dumper;


BEGIN {extends 'Catalyst::Controller::ActionRole'; }

has label_type =>
  ( is => 'rw', isa => 'Str', required => 1, default => sub { 'weiss' } );

=head1 NAME

Benno::Controller::Label - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


sub labels : Chained('/base') PathPart('etikett') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{labels} = $c->model('BennoDB::Label');
}


sub label : Chained('labels') PathPart('') CaptureArgs(1) {
	my ( $self, $c, $id ) = @_;

	$c->stash->{label} = $c->stash->{labels}->find($id) 
            or $self->error_msg($c, "Signatur mit ID $id nicht gefunden!");
}

sub labelgroup : Chained('labels') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $labelgroup_shortname ) = @_;
   
    my $labelgroups = $c->stash->{labelgroups};
    
    $c->log->debug('labelgroup: ' . $labelgroup_shortname);
    
    my $labelgroup
        = first {$_->shortname eq $labelgroup_shortname} @$labelgroups;
    $self->error_msg($c, "Signaturgruppe $labelgroup_shortname nicht gefunden!")
        unless $labelgroup;
        
    my $label_rs = $c->stash->{labels}->search({
        printed => undef,
        deleted => undef,        
    });
   
    $label_rs  = $label_rs->filter_labelgroup($labelgroup->shortname);
    $c->detach('/default') unless $label_rs;
    $c->log->debug('label_rs (count): ' .  $label_rs->count); 
    $c->stash(labels => $label_rs, labelgroup_name => $labelgroup->shortname);
}
 

sub list : Chained('labelgroup') PathPart('list') Args(0) {
    my ( $self, $c ) = @_;
    
    $c->stash(json_url => $c->uri_for_action('/label/json', $c->req->captures));
}

sub list_admin : Chained('/login/required') PathPart('list_admin') Args(0)
               :  Does(~ACL)
               :  RequiresRole(admin)
               :  ACLDetachTo(/login/login) {
    
    my ( $self, $c ) = @_;
        
    $c->stash( json_url  => $c->uri_for_action('label/json_admin') );
}



sub print :  Chained('labelgroup') PathPart('print') Args(0)
          :  Does(~ACL)
          :  AllowedRole(print)
          :  AllowedRole(admin)
          :  ACLDetachTo(denied)
{
    my ( $self, $c ) = @_;
    
    $self->print_do($c);
}


sub json : Chained('labelgroup') PathPart('json') Args(0) {
	my ( $self, $c ) = @_;

	my $data = $c->req->params;
	$c->log->debug( Dumper($data) );

	my $page             = $data->{page} || 1;
 	my $rows_per_page
            = $c->session->{rows_per_page}
            = $data->{rows} || $c->session->{rows_per_page} || 25;
	my $sidx             = $data->{sidx} || 'd11sig';
	my $sord             = $data->{sord} || 'asc';

	my $label_rs = $c->stash->{labels};

	$label_rs = $label_rs->search(
		{},
		{
			page     => $page,
			rows     => $rows_per_page,
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

sub json_admin : Chained('labels') PathPart('json_admin') Args(0) {
    my ( $self, $c ) = @_;

    my $data = $c->req->params;
    $c->log->debug( Dumper($data) );

    my $page             = $data->{page} || 1;
    my $rows_per_page = $data->{rows} || 45;
    my $sidx             = $data->{sidx} || 'd11sig';
    my $sord             = $data->{sord} || 'asc';

    my $filters = $data->{filters};
    #$filters = decode_json $filters if $filters;  #ging nicht mit utf8??    
    $filters = from_json $filters if $filters;   

    my $label_rs = $c->stash->{labels};
   
    my ($search, $labelgroup);
    
    foreach my $rule ( @{ $filters->{rules} } ) {
        my $field = $rule->{field};
        my $data = $rule->{data};
        if ($field eq 'type') {
            $labelgroup = $data;
        } else {
            $search->{"me.$field"} = { like => "%$data%" };
        }    
    }
    
    if ($labelgroup) {
        $label_rs = $label_rs->filter_labelgroup($labelgroup);    
    }
    
    $label_rs = $label_rs->search(
        $search,
        {
            page => $page,
            rows => $rows_per_page,
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
                    $label->type,
                    $label->printed
                        && $label->printed->set_time_zone('Europe/Berlin')
                        ->strftime('%d.%m.%Y') || '',
                    $label->deleted
                        && $label->deleted->set_time_zone('Europe/Berlin')
                        ->strftime('%d.%m.%Y') || '',
            ];
            push @rows, $row;
    }
    $response->{rows} = \@rows;
    $c->stash( %$response, current_view => 'JSON' );
}




sub edit : Chained('label') {
	my ( $self, $c ) = @_;
	$self->save($c);
}

sub add : Chained('labels') {
	my ( $self, $c ) = @_;
	$self->save($c);
$c->stash(title => 'Signatur eingeben');
}

# both adding and editing happens here
# no need to duplicate functionality
sub save  {
    my ( $self, $c ) = @_;

    my $label = $c->stash->{label}
        || $c->model('BennoDB::Label')->new_result({
                d11tag => 
                    DateTime->now(
                        locale      => 'de_DE',
                        time_zone   => 'Europe/Berlin',
                    ),
            });                                                              
    $c->log->debug(Data::Dumper::Dumper($c->req->params));
    my $form = Benno::Form::Label->new;
    $c->stash( template => 'label/edit.tt', form => $form );
    $form->process( item => $label, params => $c->req->params );
    if ($form->validated) {
        $c->stash(status_msg => 'Signatur ' . $label->d11sig . ' gespeichert.');
        $label = $c->model('BennoDB::Label')->new_result({
                d11tag => $label->d11tag,
                type   => $label->type,
        });
        $form->process( item => $label);
    }    
}


sub ajax : Chained('labels') {
    my ( $self, $c ) = @_;

    my $data = $c->req->params;
    $c->log->debug( Dumper($data) );

    my $oper = $data->{oper};

    if ( $oper eq 'del' )   { $self->delete($c) }
    if ( $oper eq 'print' ) { $c->forward('print_selected') }
    if ( $oper eq 'edit' )  { $c->forward('edit_selected') } 
}

sub delete  {
    my ( $self, $c ) = @_;
    
    my $data = $c->req->params;
    my $id   = $data->{id};
    my $oper = $data->{oper};
    
    my @label_ids     = split( /,/, $id );
    my $now = DateTime->now( time_zone => 'Europe/Berlin' );
    
    foreach my $label_id (@label_ids) {
        my $label = $c->model('BennoDB::label')->find($label_id);
        $label->update( { deleted => $now } );
    }
    my $response->{rows} = scalar @label_ids;
    $c->stash( %$response, current_view => 'JSON' );
}

# Should be merged with sub print 
sub print_selected  : Chained('labels')
                    :  Does(~ACL)
                    :  AllowedRole(print)
                    :  AllowedRole(admin)
                    :  ACLDetachTo(denied) {

	my ( $self, $c ) = @_;

	my $label_rs = $c->stash->{labels};
	my $data       = $c->req->params;
        my $id         = $data->{id} || 11222;
        my @label_ids = split( /,/, $id );
        $c->stash->{labels} = $label_rs->search({id => \@label_ids});
        $self->print_do($c);
}

#sub edit_selected  : Chained('labels')
#                    :  Does(~ACL)
#                    :  AllowedRole(print)
#                    :  AllowedRole(admin)
#                    :  ACLDetachTo(denied) {
#
#    my ( $self, $c ) = @_;
#    my $label_rs = $c->stash->{labels};
#    my @columns = $label_rs->result_source->columns;
#    my @primary_columns = $label_rs->result_source->primary_columns;
#    my %is_primary_column = map { $_,1 } @primary_columns;
#    my @non_primary_columns = grep { ! $is_primary_column{$_} } @columns;
#    my %is_non_primary_column = map { $_,1 } @non_primary_columns;
#    While (my ($k, $v) = %{$c->req->params}) {
#        $data->{$k} = $v || undef if $is_non_primary_column{$k};  
#    }
#    $c->log->debug(Data::Dumper::Dumper($data));
#    
#    
#    
#    
    #
    #my $data       = $c->req->params;
    #my $id         = $data->{id} || 11222;
    #delete $data->{oper};
    #delete $data->{deleted} if $data->{deleted} eq '';
    #delete $data->{printed} if $data->{printed} eq '';
    #my $row = $label_rs->find($data->{id});
    #$row->update({type => $data->{type}});
    #$c->res->redirect($c->uri_for($self->action_for('list_admin'),
    #    {status_msg => "Access Denied"}));
    #
    
#}

sub print_do {
    my ($self, $c) = @_;
    
    my $label_rs = $c->stash->{labels};
    $label_rs = $label_rs->search(
	undef,
    	{ order_by => 'd11sig' }
    );
    my $labels;
    while ( my $label = $label_rs->next ) {
	push @$labels, Benno::UI::ViewPort::Field::Signatur->new(
	    signatur_str => $label->d11sig, );
    }
    my $today =
        DateTime->now( time_zone => 'Europe/Berlin' )->strftime('%y%m%d');
    my $filename = join( '_', 'sig', $self->label_type, $today ) . '.ps';
    $c->stash(
        current_view => 'PostScript',
	template     => 'postscript/print.tt',
	etiketten    => $labels,
	etikett_typ  => 'WeissesEtikett',
    );
    if ( $c->forward('Benno::View::PostScript') ) {
        $c->response->content_type('application/postscript');
	$c->response->header( 'Content-Disposition',
		"attachment; filename=$filename" );
    }
    my $now = DateTime->now( time_zone => 'Europe/Berlin' );
    $label_rs->reset;
    while ( my $label = $label_rs->next ) {
        $label->update( { printed => $now } );
    }
}

sub denied : Private {
    my ($self, $c) = @_;
 
    $c->res->redirect(
        $c->uri_for_action('/index', {status_msg => "Access Denied"} )
    );
}

sub error_msg {
    my ($self, $c, $msg) = @_;
    
    $msg ||= 'Es ist ein Fehler aufgetreten.';
    $c->stash( error_msg => $msg );
    $c->detach('/base');
}


=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
