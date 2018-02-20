#!/usr/bin/perl -w
use strict;
use warnings;
use CGI;
use Data::Dumper;
use Options;
use States;
use Calendar;

my %settings = Options::load_settings('.vical', 
  {
    calstatus_file => '.calstatus',
    currentwidget_file => '.cw',
    widgets => 'Calendar,Weather'}
);
my $query = new CGI;
my $dir = $query->param('direction');
my $amount = $query->param('amount');
my $unit = $query->param('unit');
my $dt = States::get_temp_date($settings{'calstatus_file'});

if ($amount==0) {
  $dt = DateTime->now;
}
else {
  $dt->$dir( $unit => $amount );
}

States::save_status($dt, $settings{'calstatus_file'});

my $widget = Calendar->new($settings{'calstatus_file'});
print CGI::header("Content-type: text/html;charset=UTF-8");
print $widget->renderLayout;
