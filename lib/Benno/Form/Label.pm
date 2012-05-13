package Benno::Form::Label;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;
use utf8;

has '+item_class' => ( default =>'Label' );

has_field 'd11sig' => (
    type => 'Text',
    label => 'Signatur',
);

sub validate_d11sig {
    my ( $self, $field ) = @_; # self is the form
    unless ( UBR::Signatur->new_from_string($field->value)->is_valid ) {
        $field->add_error( 'Ungültige Signatur' );
    }
}

has_field 'd11tag' => (
    label => 'Datum',
    type => 'Date',
    format => "%d.%m.%Y",
);

#has_field 'type' => (
#    type => 'Text',
#    label => 'Typ',
#);

has_field 'type' => ( type => 'Select', 
    options => [
        { value => 'weiss', label => 'weiß'},
        { value => 'rot', label => 'rot'},
        { value => 'ama', label => 'ama'},
        { value => 'bmr', label => 'bmr'},        
        { value => 'msr', label => 'msr'},
    ]
);

has_field 'submit' => ( type => 'Submit', value => 'Speichern' );

# has '+unique_constraints' => ( default => sub { ['d11sig'] } );
has '+unique_messages' => (
   default => sub {
      { d11sig => "Diese Signatur ist bereits vorhanden." };
  }
);

no HTML::FormHandler::Moose;
1;
