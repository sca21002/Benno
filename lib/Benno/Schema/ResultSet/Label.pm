package Benno::Schema::ResultSet::Label;

use strict;
use warnings;
use Data::Dumper;

use base qw(DBIx::Class::ResultSet);

sub filter_labelgroup {
    my ($self, $labelgroup) = @_;
    
    my $labelgroup_row
        = $self->result_source->schema->resultset('Labelgroup')->find(
            { urlname => $labelgroup }
        );
    return unless $labelgroup_row;
    return $self->search( { %{$labelgroup_row->search}  } );

}

1;

