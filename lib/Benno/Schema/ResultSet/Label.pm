package Benno::Schema::ResultSet::Label;

use strict;
use warnings;
use Data::Dumper;

use base qw(DBIx::Class::ResultSet);

sub filter_label_group {
    my ($self, $labelgroup_id) = @_;
    
    my $labelgroup = $self->result_source->schema->resultset('Labelgroup')->find($labelgroup_id);
    return unless $labelgroup;
    return $self->search($labelgroup->search);

}

1;

