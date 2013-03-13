#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use UBR::Sisis::Schema;
use Benno::Schema;
use UBR::Signatur;
use DateTime::Format::MySQL;
use Carp;
use Data::Dumper;
use Log::Log4perl qw(:easy);
use IO::All;

### Logdatei initialisieren
my $logfile = "$FindBin::Bin/../../log/get_labels_from_file.log";
Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">" . $logfile,
    },
    { level   => $DEBUG,
      file    => 'STDOUT',
    },
);

my $now = DateTime->now(time_zone => 'Europe/Berlin');

INFO("get_label_from_file.pl gestartet.");

LOGDIE("Aufruf: get_labels_from_file.pl datei")
    unless @ARGV == 1;

my ($filename) = @ARGV;

my ($month_of_file, $day_of_file)  = $filename =~ /sig_(\d{2})\.(\d{2})/
    or LOGDIE("Falscher Dateiname $filename");

INFO("Tag: $day_of_file Monat: $month_of_file");

my $date_of_file = DateTime->new(
    year       => $now->year,
    month      => $month_of_file,
    day        => $day_of_file,
    time_zone => 'Europe/Berlin'
);

INFO('Date of file: ' . $date_of_file->strftime('%d.%m.%Y'));

$date_of_file = DateTime::Format::MySQL->format_datetime(
    $date_of_file
);
INFO("Date of file (MySQL): ", $date_of_file);

my @lines = io($filename)->chomp->slurp;
INFO("$filename eingelesen mit " . scalar @lines . ' Zeilen');

my $DB_sisis = "ubrsis";
my $dsn_sisis = "dbi:Sybase:server=sokrates;"
                . "database=$DB_sisis;timeout=600";
my $user_sisis = "crystal";
my $password_sisis = "***REMOVED***";
  
my $dsn_benno = 'dbi:mysql:benno';
my $user_benno = 'benno';
my $password_benno =  '***REMOVED***';
my $param_benno = {
    AutoCommit => 1,
    mysql_enable_utf8   => 1,
};


# my @branches_excluded = (1, 2, 3, 4, 6, 18);
my @branches_excluded = (1, 2, 3, 4, 6);


my $labels_excluded_reg = qr{
    \A
    (?:
        96/|215/|251/|261/|285/|300/|6301/|999/|999[2-579]|241/ARBG|W[ ] 
    )    
}xms;

my $schema_sisis = UBR::Sisis::Schema->connect(
    $dsn_sisis,
    $user_sisis,
    $password_sisis,
);

my $schema_benno = Benno::Schema->connect(
   $dsn_benno,
   $user_benno,
   $password_benno,
   $param_benno,
);

my $branches_excluded_clause = 'NOT IN (' . join(',', @branches_excluded) . ')';

# my $test_sig = '= \'40/QP 210 H459\'';


my @data;

foreach my $label (@lines) {
    next unless $label =~ m#/#; 
    $label =~ s/^\s+|\s+$//g;
    next if $label =~ $labels_excluded_reg;
    my $where_clause = " = '$label'";
    my $book_rs = $schema_sisis->resultset('D01buch')->search(
        {
            d01ort => \$where_clause,
            d01zweig => \$branches_excluded_clause,
        }
    );
    if (my $book = $book_rs->next) {
        push @data, {
                        d11sig  => $book->d01ort,
                        d01gsi  => $book->d01gsi,
                        d01entl => $book->d01entl,
                        d01mtyp => $book->d01mtyp,
                        d11tag => $now,
                    };
    }
}

foreach my $data (@data) {
    next if $data->{d11sig} =~ $labels_excluded_reg;  
    TRACE('Label: ', $data->{d11sig});
    my $label;
    eval {
        $label = UBR::Signatur->new_from_string( $data->{d11sig} );
        $data->{type} = $label->get_label_type(
            $data->{d01mtyp},
            $data->{d01entl},
        );
    };
    my $msg;
    if ($@) {
        if    ( $@ =~ /keine gueltige Signatur/) {
            $msg = 'ungültige Signatur';
            $msg .= ' (mehrfache Leerzeichen)' if $data->{d11sig} =~ /[ ]{2,}/
        }
        elsif ($@ =~ /Medientyp muss angegeben sein/) {
            $msg = 'fehlender Medientyp';
        }
        elsif ($@ =~ /Entleihbarkeitskennzeichen/) {
            $msg = 'fehlendes Entleihbarkeitskennzeichen';
        }
        else { $msg = $@ }
        $data->{type} = 'error';
    }
    $data->{d11tag} = DateTime::Format::MySQL->format_datetime(
        $data->{d11tag}
    );
    my @rows = $schema_benno->resultset('Label')->search(
        {
            d11sig => $data->{d11sig},
            d11tag => { '>=' => $date_of_file },
        },
    )->all;
    if (@rows) {
        INFO($data->{d11sig} . " bereits vorhanden!");
    }
    else {
        $schema_benno->resultset('Label')->create($data);
        if ($data->{type} eq 'error') {
            WARN($data->{d11sig}. ": " . $msg || '<ohne Fehlermeldung>')
        } else {   
            INFO($data->{d11sig} . " gespeichert!");
        }
    }    
}
INFO("get_label_form_file.pl beendet.");




