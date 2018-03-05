#!/usr/bin/perl -w
use strict;
use warnings;
use CGI;
use Data::Dumper;
use Options;
use States;
use Calendar;
use Weather;
use OrigoTudomany;
use OpenWeather;
use MetWeather;

# Get the program settings from .vical. Create one if it does not exist.
my %settings = Options::load_settings('.vical', 
  {
    calstatus_file => '.calstatus',
    currentwidget_file => '.cw',
    widgets => 'Calendar,Weather'}
);

# current_widget is the name of the widget class name which should be loaded.
# Default is 'Calendar'.
my $current_widget = States::get_current_widget($settings{'currentwidget_file'});

# calendar_status is an ISO date and time string. It helps restore the calendar 
# layout to show the date last time displayed and it will be used when the user 
# steps the calendar entries back and forth undependently on the layout.
#my $calendar_status = States::get_temp_date($settings{'calstatus_file'});

my $widgetClass = $current_widget;
exit(0) unless ($widgetClass);

# Instantiate the widget class.
# The name of the class is the widget name coming from the currentwidget_file.tmp.
my $widget = $widgetClass->new($settings{'calstatus_file'});
#$widget->saySomething($current_widget.' '.$calendar_status);

# Ask the object for its timeout value.
# The widget will be displayed for this time long.
my $timeout = $widget->getTimeout;

# Print the HTML header.
print CGI::header("Content-type: text/html;charset=UTF-8");

# Calculate the next widget which should be loaded and rendered.
# Later an array of widget names should be used and the next widget
# should be the next element in that array.
my $next_widget;
my @widgets = split /,/, $settings{widgets};
for (my $index=0; $index<=$#widgets; $index++) {
  if($widgets[$index] eq $current_widget) {
    if($index==$#widgets) {
      $next_widget = $widgets[0];
    }
    else {
      $next_widget = $widgets[$index+1];
      last;
    }
  }
}
States::save_status($next_widget, $settings{'currentwidget_file'});

# This timeout value will be splitted off from the response in 
# the end of the success ajax call.
print qq($timeout#);

# Finally send the html code generated by the widget class.
print $widget->renderLayout;
