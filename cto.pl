#!/usr/bin/perl -w
use strict;
use warnings;
use CGI;
use Options;

print CGI::header("Content-type: text/html;charset=UTF-8");

# Ask the object for its timeout value.
my $timeout = $widget->getTimeout;
print $timeout;
