use No::Dato qw(tekstdato helligdag helligdager);
use Time::Local qw(timelocal);

print "1..15\n";

$a = tekstdato(timelocal(0,0,12,2,1,97));
print "$a\n";
print "not " unless $a eq "S�ndag, 2. februar 1997";
print "ok 1\n";

# Er det noe spesielt med dagen idag?
$a = helligdag();
if ($a) {
	print "Idag er det $a\n";
} else {
	print tekstdato(), " er ingen hellig dag\n";
}

print "\n�rets helligdager er\n";
for (helligdager()) {
  print " $_\n";
}

print "\nSjekke helligdager i 1997:\n";

$testno = 2;
for ('01-01', '03-27', '03-28', '03-31', '05-01', '05-08',
     '05-17', '05-19', '12-25', '12-26') {
	print "not " unless helligdag("1997-$_");
	print "ok $testno\n";
	$testno++;
}

print "\nSjekk noen tilfeldige andre datoer:\n";
for ('01-02', '03-29', '05-30', '11-12') {
	print "not " if helligdag("1997-$_");
	print "ok $testno\n";
	$testno++;
}
