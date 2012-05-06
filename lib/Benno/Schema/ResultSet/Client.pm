package Benno::Schema::ResultSet::Client;

use strict;
use warnings;

use base qw(DBIx::Class::ResultSet);

sub client_has {
    my ($self, $address) = @_;
    
    return unless $address;

    my $client = $self->find({address => $address});
    return unless $client;
    return unless $client->can('roles');
 
    my %client_has = map {$_->name,1} $client->roles;
 
    return %client_has;    

}

sub roles {
    my ($self, $address) = @_;
    
    return unless $address;

    my $client = $self->find({address => $address});
    return unless $client;
    return unless $client->can('roles');
 
    my @roles = map {$_->name} $client->roles;
 
    return @roles;    
}


1;