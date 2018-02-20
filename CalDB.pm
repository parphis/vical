package CalDB;
use strict;
use DBI;
use Data::Dumper;
use utf8;

my $dbfile = '/calendar/calendar.sqlite';

sub conn() {
  my $dbh = DBI->connect(
    "dbi:SQLite:dbname=$dbfile",
    "", # no user
    "", # no pwd
    { RaiseError => 1 },
  ) or die $DBI::errstr;
  $dbh->{sqlite_unicode} = 1;
  return $dbh;
}

sub get_categories {
  my $dbh = &conn;

  return undef unless ($dbh);

  my $sth = $dbh->prepare("select * from category where show=1;") or die $DBI::errstr;

  $sth->execute();

  my @result;
  my $i = 0;

  while (my $row = $sth->fetchrow_hashref()) {
    push(@result, $row);
  }
  return @result;
}
sub get_category_style {
  my $dbh = &conn;

  return undef unless ($dbh);

  my $sth = $dbh->prepare("select style from category where id=?;") or die $DBI::errstr;

  $sth->execute(shift);

  while (my $row = $sth->fetchrow_arrayref()) {
    return @$row[0];
  }
}
sub get_calendar_events {
  my $dbh = &conn;

  return undef unless ($dbh);

  my $sth = $dbh->prepare("select * from event where show=1;") or die $DBI::errstr;

  $sth->execute();

  my $row;
   
  while ($row=$sth->fetchrow_hashref) {
          print Dumper $row;
  }

  return $row
}
sub get_event {
  my $dbh = &conn;
  
  return undef unless ($dbh);

  my $dt = shift;

  my $sth = $dbh->prepare("select * from event where start=? and show=1;") or die $DBI::errstr;

  $sth->execute($dt);

  my @result;
  my $i = 0;

  while (my $row = $sth->fetchrow_hashref()) {
    push(@result, $row);
  }
  return @result;
}
sub get_names_for_a_day {
  my $dbh = &conn;

  return undef unless ($dbh);

  my $sth = $dbh->prepare("select name from namedays where id=?;") or die $DBI::errstr;

  $sth->execute(shift);

  while (my $row = $sth->fetchrow_arrayref()) {
    return @$row[0];
  }
}
1;
