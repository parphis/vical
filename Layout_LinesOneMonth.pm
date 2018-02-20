package Layout_LinesOneMonth;
use DateTime;
use strict;
use events qw(get_calendar_events);

my $settings_file = '.vical';
my %settings;

# Save and load the program settings simply as key=value pairs.
# @since 2018-01-11
sub serialize_settings {
  if (open(my $fh, '>:encoding(UTF-8)', $settings_file)) {
    foreach my $i (keys %settings) {
      print $fh $i."=".$settings{$i}."\n";
    }
    close($fh);
  }
}

sub load_settings {
  if (open(my $fh, '<:encoding(UTF-8)', $settings_file)) {
    while (my $row = <$fh>) {
      chomp $row;
      my @pair = split /=/, $row;
      $settings{$pair[0]} = $pair[1];
    }
    print Dumper \%settings;
  }
  else {
    $settings{'layout'} = 'lines_one_month';
    $settings{'refresh_interval'} = 10;
    $settings{'user'} = '';
    $settings{'pwd'} = '';
    $settings{'remote_endpoint'} = '';
    serialize_settings();
  }
}

sub generate_layout {
  my $dt = DateTime->new(year => 2018, month => 1, day => 9, locale => 'hu-HU');
  my $dayname = $dt->day_name;
  my $html;
  $html = qq(
  <!doctype html>
  <html>
    <head>
      <meta charset="utf-8">
      <title>viCal</title>
    </head>
    <body>
      <div class="w3-container">
        <div class="calendar-head"></div>
        <table class="lines-one-month-table">
          <tbody>
            <tr><td>$dayname</td></tr>
          </tbody>
        </table>
      </div>
    </body>
  </html>
  );
}
sub render_layout {
  open(my $fh, '>', 'index.html') or die "Failed to save file $!";
  print $fh generate_layout();
  close $fh;
}
1;
