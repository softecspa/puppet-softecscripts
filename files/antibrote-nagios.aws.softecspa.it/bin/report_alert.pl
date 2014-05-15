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
        Subject => 'Report Nagios ' . $dt->dmy('/'),
        Type    => 'text/html',
        Data    => $content
    );

    $msg->send;
}

send_report "https://nagios.softecspa.it/cgi-bin/nagios3/summary.cgi?report=1&displaytype=2&timeperiod=last7days&smon=1&sday=1&syear=2013&shour=0&smin=0&ssec=0&emon=1&eday=14&eyear=2013&ehour=24&emin=0&esec=0&hostgroup=all&servicegroup=all&host=all&alerttypes=3&statetypes=3&hoststates=7&servicestates=120&limit=25";
