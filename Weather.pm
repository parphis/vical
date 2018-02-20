package Weather;

use strict;
use Options;

sub new {
  my $class = shift;
  my $self = { };

  $self->{_class} = $class;
  $self->{_default_timeout} = 10000; # 

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
  my $t = time();
  return qq(<div class="weather">
	            <img src="http://wx.fallingrain.com/wx.cgi?lat=47.3932&long=18.4604&name-Csakvar&what=TMP&a=$t"></img>
              <img src="http://wx.fallingrain.com/wx.cgi?lat=47.3932&long=18.4604&name-Csakvar&what=PCP&a=$t"></img>
              <img src="http://wx.fallingrain.com/wx.cgi?lat=47.3932&long=18.4604&name-Csakvar&what=CLD&a=$t"></img>
            </div>);
}
1;
