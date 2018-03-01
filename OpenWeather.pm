package OpenWeather;

use strict;
use HTTP::Tiny;
use DateTime;
use DateTime::Format::Strptime;
use XML::Simple;
$XML::Simple::PREFERRED_PARSER = 'XML::Parser';
use Storable;
use Options;
use Data::Dumper;

sub new {
  my $class = shift;
  my $self = { };

  $self->{_class} = $class;
  $self->{_default_timeout} = 10000; #
  $self->{_api_key} = '87e8cc6681f83ddd9eee03f125cc0818';
  $self->{_city_id} = '3054434';
  $self->{_api_url} = "https://api.openweathermap.org/data/2.5/forecast?id=$self->{'_city_id'}&APPID=$self->{'_api_key'}&mode=xml&units=metric&lang=hu";
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
  my $xml = HTTP::Tiny->new->get($self->{'_api_url'});
  $xml = XMLin($xml->{content});

# TODO: check if the url->get was failed, if yes load back the last status from the file
# if it was success just use the received content
  store \%$xml, 'owtemp';
  $xml = retrieve('owtemp');

  my %res = %$xml;
  #print Dumper(\%res);

  my %time = %{$res{'forecast'}};
  #print Dumper(\%time);

  my @details = @{$time{'time'}};
  #print Dumper(@details);

  my $html = "<div id='ow-cards' class='w3-container'>";

  foreach my $el (@details) {
    my %parts = %{$el};
    my $formatter = DateTime::Format::Strptime->new(pattern => '%Y-%m-%dT%H:%M:%S');
    my $dt = $formatter->parse_datetime($parts{'from'});
    my %pressure = %{$parts{'pressure'}};
    
    my $date = $self->{_month_list}{$dt->month()}." ".$dt->strftime("%d");
    my $icon = %{$parts{'symbol'}}{'var'};
    my $hour = $dt->strftime("%H:%M:%S");
    my $temp = %{$parts{'temperature'}}{'value'};
    my $wind_speed = %{$parts{'windSpeed'}}{'mps'}."m/s";
    my $wind_type = %{$parts{'windSpeed'}}{'name'};
    my $wind_dir = %{$parts{'windDirection'}}{'name'};
    my $cloud = %{$parts{'clouds'}}{'all'}.%{$parts{'clouds'}}{'unit'};
    my $precip_type = %{$parts{'precipitation'}}{'type'};
    my $precip_value = %{$parts{'precipitation'}}{'value'}."mm";
    my $humidity = %{$parts{'humidity'}}{'value'}.%{$parts{'humidity'}}{'unit'};
    my $pressure = %{$parts{'pressure'}}{'value'}.%{$parts{'pressure'}}{'unit'};

    $html .= "<div class='w3-card'>";
    $html .= "<header class='w3-container'><h3>$date</h3><img src='http://openweathermap.org/img/w/$icon.png' alt='$icon'/></header>";
    $html .= "<div class='w3-container'>";
    $html .= "<span>$hour</span>";
    $html .= "<span>$temp</span>";
    $html .= "<span>$wind_speed</span>";
    $html .= "<span>$wind_type</span>";
    $html .= "<span>$wind_dir</span>";
    $html .= "<span>$cloud</span>";
    $html .= "<span>$precip_type</span>";
    $html .= "<span>$precip_value</span>";
    $html .= "<span>$humidity</span>";
    $html .= "<span>$pressure</span>";
    $html .= "</div></div>";
  }

  $html .= "</div>";

  return qq(<div class="weather">$html</div>);
}
1;
my $ow = OpenWeather->new;
my $res = $ow->renderLayout;
print $res;
