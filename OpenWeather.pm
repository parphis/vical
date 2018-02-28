package OpenWeather;

use strict;
use HTTP::Tiny;
use JSON qw(decode_json);
use Options;

sub new {
  my $class = shift;
  my $self = { };

  $self->{_class} = $class;
  $self->{_default_timeout} = 10000; #
  $self->{_api_key} = '87e8cc6681f83ddd9eee03f125cc0818';
  $self->{_city_id} = '3054434';
  $self->{_api_url} = "https://api.openweathermap.org/data/2.5/forecast?id=$self->{'_city_id'}&APPID=$self->{'_api_key'}&mode=xml";

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
  my $response = HTTP::Tiny->new->get($self->{'_api_url'});
  
  return qq(<div class="weather">$response->{content}</div>);
}
1;
