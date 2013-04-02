#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use UBR::Sisis::Schema;
use Benno::Schema;
use UBR::Signatur;
use DateTime::Format::Strptime;
use DateTime::Format::MySQL;
use Carp;
use Data::Dumper;
use Log::Log4perl;
use Log::Log4perl::Util::TimeTracker;


my $now = DateTime->now(time_zone => 'Europe/Berlin');
my $hour = $now->hour;
my $dow  = $now->day_of_week;                                   #  (Montag = 1)

exit if $hour <= 6 and $hour >= 21;
exit if $hour != 20 and ( $dow == 6 or $dow == 7 ); 



Log::Log4perl::init("$FindBin::Bin/../../log4perl.conf");
my $root_logger = Log::Log4perl->get_logger();
my $etikett_logger = Log::Log4perl->get_logger('Etikett');
my $timer = Log::Log4perl::Util::TimeTracker->new();

$root_logger->info("get_label_from_sisis.pl gestartet.");
$root_logger->info("ENV:\n" . Dumper(%ENV));


if ($hour >= 13 and $hour < 14) {
    $etikett_logger->info("Benno wünscht einen angenehmen Nachmittag");
} 

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


my $Sybase_Strp = new DateTime::Format::Strptime(
                                pattern     => '%d.%m.%Y',
                                locale      => 'de_DE',
                                time_zone   => 'Europe/Berlin',
                                on_error    => 'croak',
);



# my @branches_excluded = (1, 2, 3, 4, 6, 18);
my @branches_excluded = (1, 2, 3, 4, 6);


my $labels_excluded_reg = qr{
    \A
    (?:
        96/|215/|251/|261/|285/|300/|6301/|9980/|999/|999[2-579]|241/ARBG|W[ ] 
    )    
}xms;

my $schema_sisis = UBR::Sisis::Schema->connect(
    $dsn_sisis,
    $user_sisis,
    $password_sisis,
);

$root_logger->logdie('Keine Verbindung zur Sisis-Datenbank') unless $schema_sisis;

my $schema_benno = Benno::Schema->connect(
   $dsn_benno,
   $user_benno,
   $password_benno,
   $param_benno,
);

$root_logger->info("Verbindung zu den Datenbanken hergestellt.");

my $branches_excluded_clause = 'NOT IN (' . join(',', @branches_excluded) . ')';

# my $test_sig = '= \'40/QP 210 H459\'';

my @labels
    = $schema_sisis
        ->resultset('D11rueck')->search(
            {
                # 'me.d11sig'   => \$test_sig,
                'me.d11zweig' => \$branches_excluded_clause,
            },
            {
                join => 'd01buch',
                '+select' => [
                            'd01buch.d01gsi',
                            'd01buch.d01entl',
                            'd01buch.d01mtyp',
                            \'CONVERT(CHAR(10), me.d11tag, 104)',
                ],
                '+as'     => [ 'd01gsi', 'd01entl',  'd01mtyp', 'd11tag' ],
            }
        );

$root_logger->info("Suche in D11rueck abgeschlossen.");

        
my @data = map { {$_->get_columns} } @labels;

foreach my $data (@data) {
    next if $data->{d11sig} =~ $labels_excluded_reg;  

    my $i++;
    $root_logger->info($i . ' Siganturen bearbeitet') if $i % 100 == 0;

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
        $Sybase_Strp->parse_datetime($data->{d11tag})
    );
    my $row = $schema_benno->resultset('Label')->find(
        {
            d11sig => $data->{d11sig},
            d11tag => $data->{d11tag},
        },
        { key => 'd11sig' }
    );
    if (defined $row) {
        $row->update($data);     
    }
    else {
        $schema_benno->resultset('Label')->create($data);
        $etikett_logger->warn($data->{d11sig}. ": " . $msg || '<ohne Fehlermeldung>')
            if $data->{type} eq 'error';
    }    
}
$root_logger->info("get_label_from_sisis.pl beendet.");




