package No::Skatt;

use strict;

use base qw(Exporter);
our @EXPORT_OK = qw(skatt);

my %satser = (
    # år     |personfradrag
    #        |       |minstefradrag %
    #        |       |   |minstefradrag minimum
    #        |       |   |      |minstefradrag maks
    #	     |       |   |      |       |Finnmarksfradrag
    #	     |       |   |      |       |       |kommunal- og fylkeskommunal skatt
    #        |       |   |      |       |       |      |fellesskatt staten
    #        |       |   |      |       |       |      |       |toppskatt %
    #        |       |   |      |       |       |      |       |  |toppskatt grense
    #        |       |   |      |       |       |      |       |  |        |toppskatt %
    #        |       |   |      |       |       |      |       |  |        |   |toppskatt grense
    #        |       |   |      |       |       |      |       |  |        |   |         |trygdeavgift, mellomsats
    #        |       |   |      |       |       |      |       |  |        |   |         |    |trygdeavgift, høy sats
    #        |       |   |      |       |       |      |       |  |        |   |         |    |     |trygdeavgift opptrappingssats
    #        |       |   |      |       |       |      |       |  |        |   |         |    |     |   |trygdeavgift nedre grense
    #        |       |   |      |       |       |      |       |  |        |   |         |    |     |   |       |formueskatt
    #        |       |   |      |       |       |      |       |  |        |   |         |    |     |   |       |    |formueskatt 0%
    2013 => [47_150, 40, 4_000, 81_300, 15_000, 14.25, 13.75, [9, 509_600, 12, 828_300], 7.8, 11.0, 25, 39_600, 1.1, 870_000],
    2012 => [45_350, 38, 4_000, 78_150, 15_000, 14.25, 13.75, [9, 490_000, 12, 796_400], 7.8, 11.0, 25, 39_600, 1.1, 750_000],
    2011 => [43_600, 36, 4_000, 75_150, 15_000, 13.95, 14.05, [9, 471_200, 12, 765_800], 7.8, 11.0, 25, 39_600, 1.1, 700_000],
    2010 => [42_210, 36, 4_000, 72_800, 15_000, 15.45, 12.55, [9, 456_400, 12, 741_700], 7.8, 11.0, 25, 39_600, 1.1, 700_000],
);

sub satser {
    my $year = shift;
    my %s;
    @s{qw(pf mf_p mf_min mf_max fmf ktax_p stax_p toptax ta2_p ta3_p tao_p ta_min ftax_p ftax_lim)} = @{$satser{$year}};
    my @t = @{$s{toptax} || []};
    $s{toptax} = \my @tt;
    while (@t) {
	push(@tt, { p => shift(@t), lim => shift(@t) });
    }
    $s{year} = $year;
    return %s;
}

sub skatt {
    my %p = @_;
    $p{year} ||= (localtime)[5] + 1900;
    $p{lonnsinntekt} ||= 0;
    $p{overskudd_naring} ||= 0;
    $p{kapitalinntekt} ||= 0;
    $p{fradrag} ||= 0;
    $p{formue} ||= 0;

    my %satser = satser($p{year});
    $p{satser} = \%satser;

    $p{personinntekt} = $p{lonnsinntekt} + $p{overskudd_naring};
    $p{bruttolonn} = $p{personinntekt} + $p{kapitalinntekt};

    $p{personfradrag} = min($satser{pf}, $p{bruttolonn});
    $p{minstefradrag} = max(min($p{lonnsinntekt}*$satser{mf_p}/100, $satser{mf_max}), $satser{mf_min});
    $p{inntekt} = max($p{bruttolonn} - $p{personfradrag} - $p{minstefradrag} - $p{fradrag}, 0);
    $p{skatt_inntekt} = $p{inntekt} * ($satser{ktax_p} + $satser{stax_p})/100;
    $p{skatt_trygdeavgift} = max(min($p{lonnsinntekt}*$satser{ta2_p}/100 + $p{overskudd_naring}*$satser{ta3_p}/100,
				         ($p{lonnsinntekt} + $p{overskudd_naring} - $satser{ta_min}) * $satser{tao_p}/100),
				     0);
    $p{skatt_formue} = max(($p{formue} - $satser{ftax_lim})*$satser{ftax_p}/100, 0);

    $p{skatt_topp} = 0;
    for (@{$satser{toptax}}) {
	$p{skatt_topp} += max(($p{personinntekt} - $_->{lim}) * $_->{p}/100, 0)
    }

    $p{skatt} = $p{skatt_inntekt} + $p{skatt_topp} + $p{skatt_trygdeavgift} + $p{skatt_formue};

    #use Data::Dump; dd \%p;
    return int($p{skatt}+0.5) unless wantarray;
    return %p;
}

sub min {
    my $min = shift;
    while (@_) {
	my $n = shift;
	$min = $n if $n < $min;
    }
    return $min;
}

sub max {
    my $max = shift;
    while (@_) {
	my $n = shift;
	$max = $n if $n > $max;
    }
    return $max;
}

1;
