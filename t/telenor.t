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
 ['1996-01-06 12:00:00',     0, "L",    "die"],  # år < 1997
 # Noen hvor varigheten er 0 sekunder
 ['1997-01-06 12:00:00',     0, "L",     0.40],
 ['1997-01-06 12:00:00',     0, "R",     0.40],

 # Noen enkle på dagen
 ['1997-01-06 12:00:00',    60, "L",     0.65],
 ['1997-01-06 12:00:00',  3600, "L",    15.40],
 # Noen enkle på natta
 ['1997-01-06 00:00:00',    60, "L",     0.54],
 ['1997-01-06 00:00:00',  3600, "L",     8.80],
 # I helga (på dagen)
 ['1997-01-05 12:00:00',    60, "L",     0.54],
 ['1997-01-05 12:00:00',  3600, "L",     8.80],

 # Litt rikstakst
 ['1997-01-06 12:00:00',    15, "R",     0.55],
 ['1997-01-06 00:00:00',  3600, "R",    30.40],

 # Noen hvor taksten skrifter underveis
 ['1997-01-06 16:30:00',  3600, "LFV",    11.26],
 ['1997-01-06 07:45:00',  3600, "LFV",    13.33],

 # Noen som har glemt å legge på røret en hel uke, med forskjellig takst
 ['1997-01-06 07:45:00', 7*24*3600, "L",    1708.60],
 ['1997-01-06 07:45:00', 7*24*3600, "LFV",  1501.96],
 ['1997-01-06 07:45:00', 7*24*3600, "R",    5310.40],
 ['1997-01-06 07:45:00', 7*24*3600, "RFV",  4248.32],
 ['1997-01-06 07:45:00', 7*24*3600, "L+",   1730.77],
 ['1997-01-06 07:45:00', 7*24*3600, "R+",   5015.17],
 ['1997-01-06 07:45:00', 7*24*3600, "M",   24192.40],
 ['1997-01-06 07:45:00', 7*24*3600, "M+",  22075.57],
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
