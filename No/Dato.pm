package No::Dato;

use Time::Local qw(timelocal);
use Carp ();

require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK = qw(tekstdato helligdag helligdager);

$VERSION = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);

use strict;
use vars qw(%SPECIAL_DAYS @UKEDAGER @MANEDER);

%SPECIAL_DAYS = (
  "Nyttårsdag"            => '01-01',
  "1. mai"                => '05-01',
  "Grunnlovsdag"          => '05-17',
  "Juledag"               => '12-25',
  "2. Juledag"            => '12-26',

  # relative to easter day
  "Skjærtorsdag"          => -3,
  "Langfredag"            => -2,
  "Påskedag"              =>  0,
  "2. Påskedag"           => +1,
  "Kristi himmelfartsdag" => +39,
  "Pinsedag"              => +49,
  "2. Pinsedag"           => +50,
);

@UKEDAGER = qw(Søndag Mandag Tirsdag Onsdag Torsdag Fredag Lørdag);
@MANEDER = qw(Januar Februar Mars      April   Mai      Juni
              Juli   August  September Oktober November Desember);

my %hellig_cache = ();

sub tekstdato (;$)
{
    my $time = shift || time;
    my($d,$m,$y,$wd) = (localtime $time)[3,4,5,6];
    sprintf "%s, %d. %s %d", $UKEDAGER[$wd], $d, $MANEDER[$m], $y+1900;
}

sub helligdag (;$)
{
    my $date = shift || time;
    my $year;
    my $weekday;
    if ($date =~ /^\d+$/) {
	my($d,$m,$y,$w) = (localtime $date)[3,4,5,6];
	$year = $y+1900;
	$weekday = $w;
	$date = sprintf "%02d-%02d", $m+1, $d;
    } elsif ($date =~ s/^(\d{4})-(\d\d-\d\d)$/$2/) {
	$year = $1;
    } else {
        Carp::croak("Bad date '$date'");
    } 
    helligdager($year) unless exists $hellig_cache{$year};
    my $day = "";
    if (exists $hellig_cache{$year}{$date}) {
	$day = $hellig_cache{$year}{$date};
    } else {
	# sjekk om det er søndag
	unless (defined $weekday) {
	    my($m, $d) = split(/-/, $date);
	    $weekday = (localtime(timelocal(12,0,0,$d, $m-1, $year-1900)))[6];
        }
        $day = "Søndag" if $weekday == 0;
    }
    $day;
}

sub helligdager (;$)
{
    my $year = shift || (localtime)[5] + 1900;

    unless (exists $hellig_cache{$year}) {
	my $easter = easter_day($year);
    
	my ($text, $date);
	while (($text, $date) = each %SPECIAL_DAYS) {
	    my($month, $mday);
	    if ($date =~ /^(\d+)-(\d+)$/) {
		# a fixed date
		($month, $mday) = ($1, $2);
	    } else {
		($month, $mday) = dayno_to_date($year, $easter + $date);
	    }
	    # sjekk om det er en søndag i tillegg
	    if ($year >= 1970 &&
		(localtime(timelocal(12, 0, 0,
				     $mday, $month-1, $year-1900)))[6] == 0) {
		$text .= " (Søndag)";
	    }
	    $hellig_cache{$year}{sprintf "%02d-%02d", $month, $mday} = $text;
	}
    }

    # we want to return a sorted array
    my @days;
    for (sort keys %{$hellig_cache{$year}}) {
	push(@days, "$year-$_ $hellig_cache{$year}{$_}");
    }
    @days;
}

sub easter_day ($)
{
    use integer;
    # The algoritm is taken from LaTeX calendar macros by  C. E. Chew, which
    # has taken the algoritm from "The Calculation of Easter", D.E.Knuth,
    # CACM April 1962 p 209.

    my $year = shift;
    my $golden;                      # year in Mentonic cycle
    my $easter;                      # easter sunday
    my $grCor;                       # Gregorian correction
    my $clCor;                       # Clavian correction
    my $epact;                       # age of calendar moon at start of year
    my $century;
    my $extra;                       # when Sunday occurs in March

    $golden = ($year / 19) * -19 + $year + 1;
    if ($year > 1582) {
	$century = ($year / 100) + 1;
	$grCor = ($century * 3) / -4 + 12;
	$clCor = (($century - 18)/ -25 + $century - 16) / 3;
	$extra = ($year * 5) / 4 + $grCor - 10;
	$epact = $golden * 11 + 20 + $clCor + $grCor;
	$epact += ($epact / 30) * -30;
	$epact += 30 if $epact <= 0;
	if ($epact == 25) {
	    $epact++ if $golden > 11;
	} else {
	    $epact++ if $epact == 24;
	}
    } else {                              # year <= 1582
	$extra = ($year * 5) / 4;
	$epact = ($golden * 11) - 4;
	$epact += ($epact / 30) * -30 + 1;
    }
    $easter = -$epact + 44;
    $easter += 30 if $easter < 21;
    $extra += $easter;
    $extra += ($extra / 7) * -7;
    $extra = -$extra;
    $easter += $extra + 7;
    # easter is now a date in march

    # convert to a dayno relative to 1. jan
    $easter += 31 + 28;   # days in january and february
    $easter++ if leap_year($year);
    $easter;
}

sub leap_year ($)
{
    my $year = shift;
    (($year % 4 == 0) && ($year % 100 != 0)) || ($year % 400 == 0);
}

sub dayno_to_date($$)
{
    my($year, $dayno) = @_;
    my @days_pr_month = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    my $maxdayno = 365;
    if (leap_year($year)) {
	$days_pr_month[1]++;
	$maxdayno++;
    }
    die "Dayno $dayno out of range" if $dayno < 1 || $dayno > $maxdayno;

    my $month = 1;
    while ($dayno > $days_pr_month[0]) {
	$month++;
	$dayno -= shift @days_pr_month;
    }

    ($month, $dayno);
}


1;
