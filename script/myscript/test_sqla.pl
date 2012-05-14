#!/usr/bin/perl -w
use strict;
use SQL::Abstract;
use feature qw(say);

 my $sql = SQL::Abstract->new;

my %where = (
    d11sig =>  [
    '-or' => 
    {'>' => '30/'},   
    [ -and => {'<' => '80/'}, {'not_like' => '180%'}, {'not_like' => '9996/%'} ]
             
    ],
    type => 'weiss',
);

my($stmt, @bind) = $sql->select('labels', '*', \%where);

say $stmt;
say join ', ',@bind;
