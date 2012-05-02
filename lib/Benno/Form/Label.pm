package Benno::Form::Label;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

has '+item_class' => ( default =>'Label' );

has_field 'd11sig' => (
    type => 'Text',
    label => 'Signatur',
);

has_field 'd11tag' => (
    label => 'Datum',
    type => 'Date',
    format => "%d.%m.%Y",
);

has_field 'typ' => (
    type => 'Text',
    label => 'Typ',
);

has_field 'typ' => ( type => 'Select', 
    options => [
        { value => 'weiss', label => 'weiß'},
        { value => 'rot', label => 'rot'},
        { value => 'ama', label => 'ama'},
        { value => 'bmr', label => 'bmr'},        
        { value => 'msr', label => 'msr'},
    ]
);

has_field 'submit' => ( type => 'Submit', value => 'Speichern' );

no HTML::FormHandler::Moose;
1;
