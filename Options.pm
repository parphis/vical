package Options;
use strict;

# Save and load the program settings simply as key=value pairs.
# @since 2018-01-11
sub serialize_settings {
  my $settings_file = shift;
  my $settings = shift;

  if (open(my $fh, '>:encoding(UTF-8)', $settings_file)) {
    foreach my $i (keys %{$settings}) {
      print $fh $i."=".%{$settings}{$i}."\n";
    }
    close($fh);
  }
  else {
    print "Nem lehetett létrehozni a beállítások fájlt\n";
  }
}
sub load_settings {
  my $settings_file = shift;
  my $default_config = shift;
  my %settings;

  if (open(my $fh, '<:encoding(UTF-8)', $settings_file)) {
    while (my $row = <$fh>) {
      chomp $row;
      my @pair = split /=/, $row;
      $settings{$pair[0]} = $pair[1];
    }
    return %settings;
  }
  else {
    if ($default_config) {
      serialize_settings($settings_file, $default_config);
      return %{$default_config};
    }
    else {
      return ();
    }
  }
}
1;
