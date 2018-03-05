package MetWeather;

use strict;
use HTTP::Tiny;
use Options;

sub new {
  my $class = shift;
  my $self = { };

  $self->{_class} = $class;
  $self->{_default_timeout} = 10000;
  $self->{_recent_url} = "http://www.met.hu/idojaras/elorejelzes/magyarorszagi_telepulesek/city_set.php?c=&id=580&t=47.378&n=18.49&cy=Csákvár";
  $self->{_forecast_url} = "http://www.met.hu/idojaras/elorejelzes/magyarorszagi_telepulesek/main.php";

  bless $self, $class;

  return $self;
}

sub getTimeout {
  my $self = shift;
  my $default_timeout = $self->{_default_timeout};
  my %settings = Options::load_settings('.'.lc($self->{_class}), {timeout => $default_timeout});
  return $self->{_default_timeout} unless ($settings{timeout});
}

sub renderLayout {
  my $self = shift;

  my $response = HTTP::Tiny->new->get($self->{'_recent_url'});
  $response = HTTP::Tiny->new->get($self->{'_forecast_url'});

  return qq(<div class="weather"><iframe id="magyarorszagi_telepulesek" src="$self->{_forecast_url}" name="magyarorszagi_telepulesek" scrolling="no" allowfullscreen="true" style="height:947px;" width="640" frameborder="0" align="top" $response->{content}</div>);
}
1;
