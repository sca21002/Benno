package UBR::Signatur;

use version; our $VERSION = qv('0.0.1');

use warnings;
use strict;
use Moose;
use feature qw(say);
use Carp;

sub new_from_string {
    my ($self, $signatur_str) = @_;
    
    #warn 'Signatur-Str: ' . $signatur_str;
    croak $signatur_str unless $signatur_str;
    my $class_name;
    if ($signatur_str =~ /\*/) {
        $class_name = 'Manuell';
    }
    elsif ($signatur_str =~ /^9991\//) {
        $class_name = 'MSR';    
    }
    else {
        $class_name = 'RVK';     
    }
    my $class = "UBR::Signatur::$class_name";
    Class::MOP::load_class($class);
    return $class->new(signatur_str => $signatur_str);
    
}


=head1 NAME

UBR::Signatur - The great new UBR::Signatur!

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
