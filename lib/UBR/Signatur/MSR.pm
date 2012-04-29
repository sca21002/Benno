package UBR::Signatur::MSR;

use version; our $VERSION = qv('0.0.1');

use warnings;
use strict;
use Moose;
use utf8;
use List::MoreUtils qw(any none pairwise);
use Data::Dumper;


extends 'UBR::Signatur::Base';

my $zeichen = qr{
    [A-ZÄÖÜa-zäöü0-9\.]
}xms;

my $auflage = qr{
    (\($zeichen+\))
}xms;

my $gruppe = qr{
    (?:
        [ ]
        ($zeichen+?)
        |
        ([-,+]$zeichen+?)
    )
}xms;

my $signatur_reg = qr{
    \A                  # Anfang des Strings
    (9991)              # LKZ 9991 Gruppe 1
    \/                  # Trenner LKZ
    ([A-ZÄÖÜ]{1,3})        # Hauptgruppe 
    $gruppe$auflage?
    (?:$gruppe$auflage?)?
    (?:$gruppe$auflage?)?
    (?:$gruppe$auflage?)?
    (?:$gruppe$auflage?)?
    \Z                  # Ende des Strings
}xms;

sub BUILDARGS {
      my $class = shift;

      if ( @_ == 1 && ! ref $_[0] ) {
          return { signatur_str => $_[0] };
      }
      else {
          return $class->SUPER::BUILDARGS(@_);
      }
}


sub _build__captures {
    my $self = shift;
    
    my $signatur = $self->signatur_str;
    my (@captures) = $signatur =~ $signatur_reg
        or die "$signatur ist keine gueltige Signatur!";
    return \@captures;       
}

sub _build_capture_keys {
    [qw(
        LKZ Hauptgruppe Gruppe1 Gruppe2 Gruppe3
        Gruppe4 Gruppe5 Gruppe6 Gruppe7 Gruppe8
        Gruppe9 Gruppe10 Gruppe11 Gruppe12 Gruppe13
        Gruppe14 Gruppe15
    )];
}

sub get_label_type { 'MSR' }

sub _build_is_valid {
    my $self = shift;    

    $self->signatur_str =~ $signatur_reg
}

=head1 NAME

UBR::Signatur::RVK 

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use UBR::Signatur;

    my $foo = UBR::Signatur->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 function1

=cut


=head2 function2

=cut


=head1 AUTHOR

Albert Schroeder, C<< <albert.schroeder at bibliothek.uni-regensburg.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<<albert.schroeder at bibliothek.uni-regensburg.de>>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc UBR::Signatur


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Albert Schroeder

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of UBR::Signatur
