#!/usr/bin/perl
# semplice script per ottenere l'elenco delle chiamate da/verso un numero
# Dexgate salva i log delle chiamate in file csv, separati per mese nel
# path /usr/local/Dexgate/cdr/cdr-yyyymm.csv: i dati vengono salvati nel file dest.csv

use 5.010;
use strict;
use warnings;
use utf8;
use Text::CSV; #libtext-csv-perl
use MIME::Lite; #libmime-lite-perl
use Getopt::Long;

my $content = "";
my $filter;
my $mon;
my $year;
my $dest;
my $fileto;

GetOptions("filter|f:s" => \$filter);

unless ( $filter =~ /[from|to]/ ){
    die "Specificare opzione filter come 'from' o 'to'\n";
}

(undef,undef,undef,undef,$mon,$year,undef,undef,undef) = localtime(time);

$year += 1900;

if ( $mon == 0 ){
    $mon = 12;
    $year -= 1;
}

open my $file, '<:encoding(latin1)', '/usr/local/Dexgate/cdr/cdr-'. $year . '' . $mon . '.csv';
if ( $filter =~ "from" ){
    $fileto="effettuate-$year$mon.csv";
    open $dest, '>:encoding(latin1)', "/tmp/$fileto";
}
else{
    $fileto="ricevute$year$mon.csv";
    open $dest, '>:encoding(latin1)', "/tmp/$fileto";
}

sub send_mail{
        my $subject = $fileto =~ /effettuate/ ? "Riepilogo chiamate effettuate" : "Riepilogo chiamate ricevute";
        my $msg = MIME::Lite->new(
                From    => 'centralino@softecspa.it',
                To      => 'federico.anderini@softecspa.it',
                Subject => $subject,
                Type    => 'text/plain',
                Data    => $content
        );

        $msg->attach(
            Type     =>'text/csv',
            Path     =>"/tmp/$fileto",
            Filename =>"$fileto",
            Disposition => 'attachment'
        );

        $msg->send('smtp','localhost');
};

print $dest "ora_inizo;durata;numero_chiamante;numero_chiamato;note\n";

my $csv = Text::CSV->new({sep_char => ';', binary => 1 }) or die "Cannot use CSV: ".Text::CSV->error_diag ();
$csv->eol("\n");

while ( my $row = $csv->getline($file) ){
    #usare @$row[16] per filtrare il numero destinazione, @$row[6] per il numero chiamante
    if ( $filter =~ "from" ) {
        if ( @$row[6] =~ /\A23[0-9]\Z/ ) {
            my $hours = int(@$row[5] / 3600);
            my $minutes = int(@$row[5] / 60);
            my $seconds = @$row[5] % 60;
            print $dest "@$row[1];$hours:$minutes:$seconds;@$row[6];@$row[16]\n" ;
        }
    }
    elsif ( $filter =~ "to" ){
        if ( @$row[16] =~ /filtro_telecom_gold/ | @$row[16] =~ /\A909\Z/ | @$row[16] =~ /\Afiltro_installazioni/ | @$row[16] =~ /\Afiltro_telecom_silver/ | @$row[16] =~ /\Afiltro_telecom_bronze/ | @$row[16] =~ /\Afiltro_telecom_mobiletornado_gold/ | @$row[16] =~ /92[1-5]/ ) {
            my $hours = int(@$row[5] / 3600);
            my $minutes = int(@$row[5] / 60);
            my $seconds = @$row[5] % 60;
            given (@$row[16]){
                when (@$row[16] =~ /909/ ) {print $dest "@$row[1];$hours:$minutes:$seconds;@$row[6];@$row[16];Helpdesk Telecom 0574587709\n" ;}
                when (@$row[16] =~ /925/ ) {print $dest "@$row[1];$hours:$minutes:$seconds;@$row[6];@$row[16];Helpdesk Dimensione Danza\n" ;}
                when (@$row[16] =~ /filtro_telecom_gold/ || @$row[16] =~ /923/ ) {print $dest "@$row[1];$hours:$minutes:$seconds;@$row[6];@$row[16];Helpdesk SLA Gold\n" ;}
                when (@$row[16] =~ /filtro_telecom_silver/ || @$row[16] =~ /922/ ) {print $dest "@$row[1];$hours:$minutes:$seconds;@$row[6];@$row[16];Helpdesk SLA Silver\n" ;}
                when (@$row[16] =~ /filtro_telecom_bronze/ || @$row[16] =~ /921/ ) {print $dest "@$row[1];$hours:$minutes:$seconds;@$row[6];@$row[16];Helpdesk SLA Bronze\n" ;}
                when (@$row[16] =~ /filtro_telecom_mobiletornado_gold/ || @$row[16] =~ /924/ ) {print $dest "@$row[1];$hours:$minutes:$seconds;@$row[6];@$row[16];Helpdesk Dimensione Danza\n" ;}
            }
        }
    }
}

close $file;
close $dest;

send_mail;

unlink "/tmp/$fileto";
