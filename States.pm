package States;

use strict;
use DateTime::Format::Strptime;
use Data::Dumper;

# Given a status data the function stores it in the 
# status file for later use
# Example: it can store the YYYY.MM.DDTHH:nn:ss value of 
# the date which is the base date when rendering the 
# calendar with a specific layout.
#
# @param $status {variable} - what to save.
# @param $fn {string} - temporary file.
# @returns {DateTime} - the saved data.
# @since 2018-01-10
sub save_status {
  my $status = shift;
  my $fn = shift;

  open(my $newf, '>:encoding(UTF-8)', $fn) or die ("Could not open $fn $!");
  if($newf) {
    print $newf $status;
    close($newf);
  }
  else {
    print "Error opening $fn";
  }
  return $status;
}

# Load in the date value which will be the base point 
# when rendering the layout.
# If the file does not exists use and save the today's date.
#
# @param {string} - the name of the temp file.
# @returns {DateTime} - the base point date time hash.
# @since 2018-01-10
sub get_temp_date {
  my $csf = shift;
  if (open(my $fh, '<:encoding(UTF-8)', $csf)) {
    my $row = <$fh>;
    chomp $row;
    if ($row eq '') {
      return save_status(DateTime->today, $csf);
    }
    my $strpt = DateTime::Format::Strptime->new( pattern => "%FT%T");
    my $dt = $strpt->parse_datetime($row);
    return $dt;
  } else {
    return save_status(DateTime->today, $csf);
  }
}

# Same as the get_temp_date but manages the name of the currently
# loaded widget. The widget name is case sensitive!
#
# @param {string} - the name of the temp file.
# @returns {string} - the name of the widget currently loaded.
sub get_current_widget {
  my $cwf = shift;
  if (open(my $fh, '<:encoding(UTF-8)', $cwf)) {
    my $row = <$fh>;
    chomp $row;
    if ($row eq '') {
      return save_status('Calendar', $cwf);
    }
    return $row;
  } else {
    return save_status('Calendar', $cwf);
  }
}
1;
