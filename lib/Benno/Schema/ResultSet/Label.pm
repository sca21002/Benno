package Benno::Schema::ResultSet::Label;

use strict;
use warnings;
use Data::Dumper;

use base qw(DBIx::Class::ResultSet);

sub filter_label_group {
    my ($self, $label_group) = @_;
    
    warn 'LABEL_GROUPS ' . Dumper($self->result_source->label_groups);
        
    return $self->search({});

}

1;

