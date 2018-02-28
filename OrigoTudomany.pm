package OrigoTudomany;

use strict;
use Options;
use HTTP::Tiny;
use XML::Simple;

sub new {
  my $class = shift;
  my $self = { };

  $self->{_class} = $class;
  $self->{_default_timeout} = 10000; # 
  $self->{_url} = 'http://www.origo.hu/contentpartner/rss/tudomany/origo.xml';

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

  my $xml = HTTP::Tiny->new->get($self->{_url});
  $xml = XMLin($xml->{content});
  my %channel = %{%$xml{'channel'}};
  my $html .= qq(
    <article id="origo-hu-tudomany" class="main_article">
    <h2>
      <a href="$channel{'link'}" target="_blank" class="w3-round w3-light-blue w3-padding w3-small w3-center w3-fwfont">$channel{'title'}</a>
    </h2>);
  my @items = $channel{'item'};
  for my $item (@items) {
    for my $it (@$item) {
      $html .= qq(<div class="w3-light-grey w3-topbar w3-border-blue">
        <article class="feed">);
      $html .= qq(<div class="w3-container">);
      $html .= qq(<p class="w3-tiny">${$it}{'pubDate'}</p>);
      $html .= qq(<h3><a href="${$it}{'link'}" target="_blank" class="w3-round w3-border w3-small w3-padding w3-fwfont">${$it}{'title'}</a></h3>);
      $html .= qq(<img src="${$it}{'media:thumbnail'}{'url'}" alt="" style="width:250px;height:250px;"/>) if (${$it}{'media:thumbnail'});
      $html .= qq(<p class="w3-small w3-justify w3-articlefont">${$it}{'description'}</p>
        </div>
      </article></div>);
    }
  }

  return qq(<div>$html</div>);
}
1;
