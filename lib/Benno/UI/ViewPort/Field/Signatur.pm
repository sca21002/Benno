package Benno::UI::ViewPort::Field::Signatur;
use Moose;
use UBR::Signatur;
use Data::Dumper;

has 'signatur_str' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has 'is_quer' => (
    is => 'ro',
    isa => 'Bool',
    lazy_build => 1,                  
);

has 'signatur' => (
    is => 'ro',
    isa => 'Object',
    lazy_build => 1,
);

has 'sig_arrayref' => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

sub _build_is_quer {
    my $self = shift;
    
    my $signatur = $self->signatur;
    my $quer =
            ref $signatur eq 'UBR::Signatur::RVK'
            && $signatur->is_grobsignatur
            && ( grep { $_ eq $signatur->sig_hashref->{LKZ} } ('23', '24') )
            && ( scalar @{ $signatur->sig_arrayref } == 3 )
            && (  length($signatur->sig_hashref->{Nummer}) <= 9 ) 
        ;
    return $quer;
}


sub _build_sig_arrayref {
    my $self = shift;
    
    my @sigs;
    my @sig_arrayrefs = @{$self->signatur->sig_arrayref};
    for (my $i = 0; $i <= $#sig_arrayrefs; $i++) {
        if (defined $sig_arrayrefs[$i]) {
            my $name = $sig_arrayrefs[$i]{name};
            my $value = $sig_arrayrefs[$i]{value};
            if (length $value > 9 and $value =~ /^.+,.+$/ ) {
                my ($part1, $part2) = split(/,/, $value, 2);
                push @sigs, { name => $name . '_1', value => $part1 . ',' };
                push @sigs, { name => $name . '_2', value =>  $part2 };
            } else {
                push @sigs, { name => $name, value =>  $value };
            }
        }
    }
    
    shift @sigs if grep { $sigs[0]{value} eq $_ } ('9991', '9996', '9998');
    
    # Gibt es mehr als 7 Elemente?
    while (scalar @sigs > 7) {
        my $min;
        $min->{len} = 999;
        for (my $i = 3; $i < $#sigs; $i++) { 
            my $len = length($sigs[$i]{value}) + length($sigs[$i+1]{value});
            $min = { index => $i, len => $len } if ($len < $min->{len});
        }
        splice(
            @sigs, $min->{index}, 2,
            {
                name  => $sigs[$min->{index}]->{name}
                         . '_'
                         .  $sigs[$min->{index}+1]->{name}
                         ,
                value => $sigs[$min->{index}]->{value}
                         .  $sigs[$min->{index}+1]->{value}
            }
        );
    }
    
    @sigs = map { $_ || {name => '', value => ''} } @sigs[0..6];
    for (my $i = 0; $i <= 6; $i++) { $sigs[$i]{index} = $i+1 }
    return \@sigs;
}

sub _build_signatur { UBR::Signatur->new_from_string((shift)->signatur_str) }

no Moose;
__PACKAGE__->meta->make_immutable;

1;
