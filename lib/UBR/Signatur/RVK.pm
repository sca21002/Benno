package UBR::Signatur::RVK;

use version; our $VERSION = qv('0.0.1');

use warnings;
use strict;
use Moose;
use List::MoreUtils qw(any none pairwise);

extends 'UBR::Signatur::Base';

has 'teilezahl' => (
    is => 'ro',
    isa => 'Int',
    lazy_build => 1,
);


has 'is_grobsignatur' => (
    is => 'ro',
    isa => 'Bool',
    lazy_build => 1,
);

my $cutterung = qr(
    [A-Z]           # ein Großbuchstabe 
    [0-9]{1,3}      # 1-3 Ziffern         "0" ergaenzt wegen ST 250
)xms;

my $auflage = qr{
    \(              # ein Klammer
    (?! \) )        # danach aber keine schliessende Klammer
    (?:
        [0-9]{1,3}  # 1-3 Ziffern  
    )?              # Auflage
    (?:
        \.          # ein Punkt
        [0-9]{1,3}  # 1-3 Ziffern
    )?              # Jahr der Auflage
    \)   
}xms;

my $band = qr(
    [A-Z0-9]{1,5}
    (?:ff)?                             # ff
    (?:$auflage)?
)xms;

my $band_gliederung = qr(
    $band                               # Band
    (?:
        ,                               
        $band                           # 1. Untergliederung
        (?:
            ,
            $band                       # 2. Untergliederung
            (?:
                ,
                $band                   # 3. Untergliederung
            )?
        )?
    )?
    
)xms;

my $bandangabe = qr(
    -
    $band_gliederung
    (?:
        [\/\.]                            # angeb. Baende
        $band_gliederung
    )?
    (?:
        [\/\.]                            # angeb. Baende
        $band_gliederung
    )?
    (?:
        [\/\.]                            # angeb. Baende
        $band_gliederung
    )?
    (?:[ ]u\.a\.)?                        # u.a.
)xms;



my $signatur_reg = qr{
    \A                  # Anfang des Strings
    ([0-9]{2,4}|SL[ ]01)  # LKZ, beliebige Zeichen, Gruppe 1
    \/                  # Trenner LKZ
    (?:
        ([A-Z])                 # Hauptgruppe, Gruppe 2
        ([0-9]{5,7})            # lfd. Nummer, Gruppe 3
        ($bandangabe)?          # Bandangabe, Gruppe 4
        |                       # oder
        ([A-Z]{2})              # Untergruppe, Gruppe 5
        [ ]                     # Leerzeichen
        ([0-9]{3,6})            # Feingruppe, Gruppe 6
        (?:
            [ ]             # Leerzeichen
            ($cutterung)    # 1. Cutterung, Gruppe 7
            (?:
                [ ]             # Leerzeichen
                ($cutterung)    # 2. Cutterung, Gruppe 8            
                (?:
                    [ ]             # Leerzeichen
                    ($cutterung)    # 3. Cutterung, Gruppe 9            
                )?
            )?
        )?
        (?:
            (
                \.
                [A-Z0-9]{1,4}   
            )                   # Ausgabenbez, Gruppe 10
        )?                  # Ausgabe, einmal oder keinmal
        (?:
            [ ]             # Leerzeichen
            ($cutterung)    # Gruppe 11
         
        )?                  # Cutterung hinter Ausgabe, einmal oder keinmal
        (?:
            ($auflage)      # Gruppe 12 
        )?                  # Auflage vor Bandangabe, einmal oder keinmal                                
        (?:
            ($bandangabe)   # Gruppe 13
        )?
    )
    (?:
        (
            \+          # ein Plus
            [1-9]       # keine 0 vorne
            [0-9]{0,2}  # max +999
        )               # Gruppe 14
    )?                  # Exemplar, einmal oder keinmal
    \Z                  # Ende des Strings
}xms;


my %lkz_for_extern = ('9998' => 'AMA', '9996' => 'BMA');

my @lkz_weiss = ('13', '1301',
                 '7310', '8015', '8016', '802', '803', '8441',
                 '9112', '9113', '9113', '9114', '9115', '9116', '9117',
                 '927',  '931', '9310');

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
        LKZ         Hauptgruppe Nummer      Grobsignatur_Band
        Untergruppe Feingruppe  Cutterung_1 Cutterung_2
        Cutterung_3 Ausgabe     Cutterung_4 Auflage
        Band        Exemplar
    )];
}


sub _build_teilezahl {
    return  scalar @{(shift)->sig_arrayref};
}

sub _build_is_grobsignatur {
    my $self = shift;
    
    return defined($self->sig_hashref->{Hauptgruppe});
}

sub get_label_type {
    my $self = shift;
    my $media_type = shift;
    my $borrowing_flag = shift;
    
    confess "Medientyp muss angegeben sein!" unless $media_type;
    confess "Entleihbarkeitskennzeichen muss angegeben werden!"
        unless defined $borrowing_flag;
    
    my $lkz = $self->sig_hashref->{LKZ};
    my $untergruppe = $self->sig_hashref->{Untergruppe};
    
    return $lkz_for_extern{$lkz} if $lkz_for_extern{$lkz};
    
    return 'rot'  if $lkz eq '19'
                or $lkz eq '400'
                or $borrowing_flag eq 'X' 
                    and  any{ $media_type == $_ } (3..7, 31, 33)
                    and  (
                        !defined($untergruppe)
                        or substr($untergruppe, 1, 1) ne 'A'
                        or $lkz eq '64'
                    )
                    and none { $lkz eq $_ } @lkz_weiss
                ;
    return 'weiss';
}

sub _build_is_valid { (shift)->signatur_str =~ $signatur_reg }


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
