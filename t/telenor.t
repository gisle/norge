eval { require HTTP::Date; };
if ($@) {
    print "1..0\n";
    print $@;
    exit;
}
HTTP::Date->import('str2time');

#BEGIN { $No::Telenor::DEBUG = 1; }
use No::Telenor qw(samtale_pris);

# 1996-01-06 er en mandag

@calls = (
 ['1999-06-20 12:00:00',     0, "N",    "die"],  # dato < 1999-07-01
 # Noen hvor varigheten er 0 sekunder
 ['1999-07-01 12:00:00',     0, "N",     0.45],
 ['1999-07-01 12:00:00',     0, "181",   6.00],

 # Noen enkle på dagen
 ['2000-01-06 12:00:00',    60, "N",     0.67],
 ['2000-01-06 12:00:00',  3600, "N",    13.65],
 # Noen enkle på natta
 ['2000-01-06 00:00:00',    60, "N",     0.59],
 ['2000-01-06 00:00:00',  3600, "N",     8.85],
 # I helga (på dagen)
 ['2000-01-05 12:00:00',    60, "N",     0.67],
 ['2000-01-05 12:00:00',  3600, "N",    13.65],

 # Noen hvor taksten skrifter underveis
 ['2000-01-06 16:30:00',  3600, "N",    11.25],
 ['2000-01-06 07:45:00',  3600, "N",    12.45],

 # Noen som har glemt å legge på røret en hel uke, med forskjellig takst :-)
 ['2000-01-06 07:45:00', 7*24*3600, "N",     1_627.65],
 ['2000-01-06 07:45:00', 7*24*3600, "TM",   17_035.65],
 ['2000-01-06 07:45:00', 7*24*3600, "NC",   18_850.05],
 ['2000-01-06 07:45:00', 7*24*3600, "180", 103_680.45],
 ['2000-01-06 07:45:00', 7*24*3600, "181", 144_006.00],
);

print "1..", scalar(@calls), "\n";

$no = 1;
for (@calls) {
    my($start, $varighet, $takst, $forventet) = @$_;
    print "$start $varighet $takst\n";
    my $pris;
    eval {
	$pris = samtale_pris(str2time($start), $varighet, $takst);
    };
    if ($@) {
	print "not " unless $forventet eq "die";
    } else {
	if ($forventet eq "die" || abs($pris - $forventet) > 0.005) {
	    printf "Kalkulert pris: %.2f, Forventet: %.2f\n",
	           $pris, $forventet;
	    print "not ";
	}
    }
    print "ok $no\n";
    $no++;
}
