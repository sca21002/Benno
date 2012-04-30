package Benno::Schema::ResultSet::Label;

use strict;
use warnings;

use base qw(DBIx::Class::ResultSet);

sub filter_type {
    my ($self, $type) = @_;
    
    return $self->search({});

}

1;

