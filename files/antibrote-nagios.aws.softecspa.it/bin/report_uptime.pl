#!/usr/bin/perl

use strict;
use warnings;
use MIME::Lite;         #libmime-lite-perl
use WWW::Mechanize;     #libwww-mechanize-perl
use DateTime;           #libdatetime-perl
use Getopt::Long;

my $mailto = "notifiche\@softecspa.it";

GetOptions("mailto|m:s" => \$mailto);

my $dt = DateTime->now(time_zone => 'Europe/Rome');

sub send_report {
    my $url = shift;
    my $mech = WWW::Mechanize->new();
    $mech->credentials( 'softec' => 'Xnt2gixnagios');

    $mech->agent_alias( 'Windows IE 6' );
    $mech->get($url);
    my $content = $mech->content;

    my $msg = MIME::Lite->new(
        From    => 'nagios@softecspa.it',
        To      => $mailto,
        Subject => 'Report Uptime ' . $dt->dmy('/'),
        Type    => 'text/html',
        Data    => $content
    );

    $msg->send;
}

send_report "https://nagios.softecspa.it/cgi-bin/nagios3/avail.cgi?show_log_entries=&host=aspalo01&service=all&timeperiod=lastmonth&smon=1&sday=1&syear=2013&shour=0&smin=0&ssec=0&emon=1&eday=24&eyear=2013&ehour=24&emin=0&esec=0&rpttimeperiod=&assumeinitialstates=yes&assumestateretention=yes&assumestatesduringnotrunning=yes&includesoftstates=no&initialassumedservicestate=0&backtrack=4";

sleep 5;

send_report "https://nagios.softecspa.it/cgi-bin/nagios3/avail.cgi?show_log_entries=&servicegroup=Backuppc+Hosts&timeperiod=lastmonth&smon=1&sday=1&syear=2013&shour=0&smin=0&ssec=0&emon=1&eday=29&eyear=2013&ehour=24&emin=0&esec=0&rpttimeperiod=&assumeinitialstates=yes&assumestateretention=yes&assumestatesduringnotrunning=yes&includesoftstates=no&initialassumedhoststate=0&initialassumedservicestate=0&backtrack=4";
