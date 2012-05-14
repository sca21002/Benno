package Benno::ActionRole::ACL;
use Moose::Role;
use namespace::autoclean;
use Data::Dumper;

 
sub BUILD { }
 
after BUILD => sub {
    my $class = shift;
    my ($args) = @_;
 
    my $attr = $args->{attributes};
 
    unless (exists $attr->{RequiresRole} || exists $attr->{AllowedRole}) {
        Catalyst::Exception->throw(
            "Action '$args->{reverse}' requires at least one RequiresRole or AllowedRole attribute");
    }
    unless (exists $attr->{ACLDetachTo} && $attr->{ACLDetachTo}) {
        Catalyst::Exception->throw(
            "Action '$args->{reverse}' requires the ACLDetachTo(<action>) attribute");
    }
};
 
 
around execute => sub {
    my $orig = shift;
    my $self = shift;
    my ($controller, $c) = @_;
 
    $c->log->debug('IP-Adresse: '. $c->req->address);
 
    if ($self->can_visit($c)) {
        $c->log->debug('can_visit is true');
       return $self->$orig(@_);
    }
 
    $c->log->debug('not allowed');
    my $denied = $self->attributes->{ACLDetachTo}[0];
 
    $c->detach($denied);
};

sub client_has {
    my ($self, $c) = @_;
     
    return $c->model('BennoDB::Client')->client_has($c->req->address);

}

sub user_has {
    my ($self, $c) = @_;
 
    my $user = $c->user;
 
    return unless $user;
 
    return unless $user->supports('roles') && $user->can('roles');
 
    my %user_has = map {$_,1} $user->roles;
    
    return %user_has;
}



sub can_visit {
    my ($self, $c) = @_;
    
    my %user_has = ( $self->user_has($c), $self->client_has($c) );
    return unless %user_has;
 
    my $required = $self->attributes->{RequiresRole};
    my $allowed = $self->attributes->{AllowedRole};
 
    if ($required && $allowed) {
        for my $role (@$required) {
            return unless $user_has{$role};
        }
        for my $role (@$allowed) {
            return 1 if $user_has{$role};
        }
        return;
    }
    elsif ($required) {
        for my $role (@$required) {
            return unless $user_has{$role};
        }
        return 1;
    }
    elsif ($allowed) {
        for my $role (@$allowed) {
            return 1 if $user_has{$role};
        }
        return;
    }
 
    return;
}
 
 
 
 
 
1;
