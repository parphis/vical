package Calendar;

use strict;
use DateTime;
use Data::Dumper;
use Options;
use States;
use CalDB;
use utf8;

sub new {
  my $class = shift;
  my $self = { };

  $self->{_class} = $class;
  $self->{_default_timeout} = 10000;
  $self->{_state_file} = shift;
  $self->{_month_list} = {
    1 => 'január',
    2 => 'február',
    3 => 'március',
    4 => 'április',
    5 => 'május',
    6 => 'június',
    7 => 'július',
    8 => 'augusztus',
    9 => 'szeptember',
    10 => 'október',
    11 => 'november',
    12 => 'december'
  };

  bless $self, $class;

  return $self;
}

sub getTimeout {
  my $self = shift;
  my $default_timeout = $self->{_default_timeout};
  my %settings = Options::load_settings('.'.lc($self->{_class}), {timeout => $default_timeout});
  return $self->{_default_timeout} unless ($settings{timeout});
}

sub saySomething {
  my $self = shift;
  my $something = shift;
  print "Hello from $self->{_class}: $something.\n" unless $something eq '';
}

sub renderLayout {
  my $self = shift;

  # check the today's hour, if it is midnight we change the 
  # content of the clastatus file to today, assuming that 
  # noone will use the manually paging feature at midnight
  my $today = DateTime->now;
  States::save_status($today, $self->{_state_file}) if ($today->hour==0);

  # read out the date and time value from the calstatus file
  # this will be the base point when generating the layout.
  my $dt = States::get_temp_date($self->{_state_file});

  # change the localization to `HU`
  $dt->set_locale('hu_HU');

  my $day_name = $dt->day_name;
  my $start_day = $dt->day();
  my $day_class;
  my $day;
  my $days_to_show = 30;
  my $year = $dt->year();
  my $month = $self->{_month_list}{$dt->month()};

  my $layout_type = 'lines-one-month-table';

  my $container_start = qq(<div id="w3-container">);
  my $container_end = qq(</div>);
  my $category_color;

  my @categories = CalDB::get_categories;
  my $category;

  my $head = qq(
    <div>
      <div class="calendar-head">$year. $month
        <ul class ="category-explanation">);
          foreach my $it (@categories) {
            $category_color = ${$it}{'style'};
            $category = ${$it}{'name'};
            $head .= qq(<li class="w3-$category_color">);
            $head .= ${$it}{'name'};
            $head .= qq(</li>);
          }
  $head .= qq(</ul>
      </div>
    </div>
  );
  my $subject;
  my $names;
  my $cal_table_start = qq(<table class='$layout_type'><tbody>);
  my $cal_table_end = qq(</tbody></table>);
  my $cal_table_lines;

  $dt->subtract( days => ($days_to_show/2) );
  $dt->set_hour(0);
  $dt->set_minute(0);
  $dt->set_second(0);

  $category_color = '';

  my @events;

  for (my $i = 0; $i <= $days_to_show; $i++) {
    my $dtstr = $dt;
    $dtstr =~ s/T/ /g;
    @events = CalDB::get_event($dtstr);
    #print @events."<br />";

    my $subjects = '';
    my $category_list = '';

    $day = $dt->day();
    $day_name = $dt->day_name();
    $day_class = '';
    $day_class .= ' today-0 ' if ($dt->day() == $start_day);
    $day_class .= ' weekend ' if ( ($dt->day_of_week()==6) or ($dt->day_of_week()==7) );
   
    $cal_table_lines .= qq(
      <tr>
        <td style='width:130px' class='$day_class'>$day. $day_name</td>);
    foreach my $it (@events) {
      my $style = CalDB::get_category_style(${$it}{'category_id'});
      $category_list .= qq(<div class='category-bubble' style='background-color:$style'></div>) if ($style);
      $subjects .= qq(<span class='subject'>| ${$it}{'subject'}</span>) if (${$it}{'subject'});
    }
    $cal_table_lines .= qq(<td style='width:40px'>$category_list</td><td>$subjects</td>);

    my $names = CalDB::get_names_for_a_day($dt->strftime('%m_%d'));
    $cal_table_lines .= qq(<td><div class='names'><sub>$names</sub></div></td>) if ($names);
    $cal_table_lines .= qq(</tr>);

    $dt->add( days => 1 );
  }

  my $layout = qq(
    $container_start
    $head
    $cal_table_start
    $cal_table_lines
    $cal_table_end
    $container_end
  );
  return $layout;
}
1;
