package OpenWeather;

use strict;
use HTTP::Tiny;
use DateTime;
use DateTime::Format::Strptime;
use XML::Simple;
$XML::Simple::PREFERRED_PARSER = 'XML::Parser';
use Storable;
use utf8;
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
  $self->{_precip_trans} = {
    'snow' => 'HÓ',
    'rain' => 'ESŐ'
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

  my $html = "<div id='ow-cards' class='w3-container' style='font-family:Arial !important;'>";
  my $max = 25;
  my $i = 0;

  foreach my $el (@details) {
    my %parts = %{$el};
    my $formatter = DateTime::Format::Strptime->new(pattern => '%Y-%m-%dT%H:%M:%S');
    my $dt = $formatter->parse_datetime($parts{'from'});
    my %pressure = %{$parts{'pressure'}};
    
    $dt->set_locale('hu_HU');
    my $date = $self->{_month_list}{$dt->month()}." ".$dt->strftime("%d")." ".$dt->day_name;
    my $icon = %{$parts{'symbol'}}{'var'};
    my $hour = $dt->strftime("%H:%M");
    my $temp = %{$parts{'temperature'}}{'value'}."°C";
    my $wind_speed = %{$parts{'windSpeed'}}{'mps'}."m/s";
    #my $wind_type = %{$parts{'windSpeed'}}{'name'};
    #my $wind_dir = %{$parts{'windDirection'}}{'name'};
    my $cloud = %{$parts{'clouds'}}{'all'}.%{$parts{'clouds'}}{'unit'};
    my $precip_type = $self->{_precip_trans}{%{$parts{'precipitation'}}{'type'}};
    my $pv = %{$parts{'precipitation'}}{'value'};
    $pv *= 1000;
    my $precip_value = ($pv)?sprintf("%d", $pv):"-";
    my $humidity = %{$parts{'humidity'}}{'value'}.%{$parts{'humidity'}}{'unit'};
    my $pressure = %{$parts{'pressure'}}{'value'}.%{$parts{'pressure'}}{'unit'};

    $html .= "<div class='w3-card w3-text-black' style='width:20% !important;height:200px !important;float:left;'>";
    $html .= "<header class='w3-container' style='text-align:right;position:relative;'><h5>$date</h5><img src='http://openweathermap.org/img/w/$icon.png' alt='$icon' style='width:64px;height:64px;position:absolute;top:0px;left:0px;'/>$hour</header>";
    $html .= "<div class='w3-panel'><img src='images/thermometer.svg' style='width:16px;height:16px;' /> $temp <img src='images/cloud-rain.svg' style='width:16px;height:16px;' /> $precip_type $precip_value</div>";
    $html .= "<div class='w3-panel'><img src='images/wind.svg' style='width:16px;height:16px;' /> $wind_speed</div>";
    $html .= "<div class='w3-panel'><img src='images/cloud.svg' style='width:16px;height:16px;' /> $cloud <img src='images/droplet.svg' style='width:16px;height:16px;' /> $humidity</div>";
    #$html .= "<div class='w3-panel'><img src='images/droplet.svg' style='width:16px;height:16px;' />$humidity</div>";
    #$html .= "<div class='w3-panel'><img src='images/target.svg' style='width:16px;height:16px;' />$pressure</div>";
    $html .= "</div>";

    $i++;
    last if($i==$max);
  }

  $html .= "</div>";

  return qq(<div class="weather">$html</div>);
}
1;
#my $ow = OpenWeather->new;
#my $res = $ow->renderLayout;
#print $res;
