package UBR::Signatur::Base;

use version; our $VERSION = qv('0.0.1');

use warnings;
use strict;
use Moose;
use List::MoreUtils qw(any none pairwise);

has capture_keys => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
    lazy_build => 1,
);

has 'signatur_str' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has 'sig_arrayref' => (
    is => 'ro',
    isa => 'ArrayRef[HashRef[Str]]',
    lazy_build => 1,
);

has 'sig_hashref' => (
    is => 'ro',
    isa => 'HashRef[Maybe[Str]]',
    lazy_build => 1,
);


has '_captures' => (
    is => 'ro',
    isa => 'ArrayRef[Maybe[Str]]',
    lazy_build => 1,                    
);

has 'is_valid' => (
    is => 'ro',
    isa => 'Bool',
    lazy_build => 1,                  
);


sub _build_sig_arrayref {
    my $self = shift;
    
    my @arr;
    my @captures = @{$self->_captures};
    for (my $i = 0; $i <= $#captures; $i++) {
        push @arr, { name => $self->capture_keys->[$i], value =>  $captures[$i] }
            if defined $captures[$i];
    }
    return \@arr;
}

sub _build_sig_hashref {
    my $self = shift;
    
    return { pairwise { ($a, $b) } @{$self->capture_keys}, @{$self->_captures}};
}


=head1 NAME

UBR::Signatur::Base

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
