print "1..43\n";

use No::KontoNr qw(kontonr_ok modulus_10);

$testno = 1;

print "Noen gyldige bankkontonummer...\n";
for ('52050603512',
     '5205 06 03512',  # space skal være lov
     '5205.06.03512',  #
     '05711675827',
     '65040503190',
     '08065989728',
     '90010705990',
     '08063873080',
     '05409926853',
     '52050681602',
     '08135205851',
     '20850500186',
     '08015444674',
     '82000148888',
     '08260122720',
     '82000127287',
     ) {
    print "not " unless kontonr_ok($_);
    print "ok $testno\n";
    $testno++;
}

print "Noen ugyldige bankkontonummer...\n";
for ('520506035123',  # for langt
     '520506035',     # for kort
     '5205-06-03512',
     undef,
     '52050603513',
     '52050603514',
     '52050603515',
     '52050603516',
     '52050603517',
     '52050603518',
     '52050603519',
     '52050603510',
     '52050603511',
     ) {
    print "not " if kontonr_ok($_);
    print "ok $testno\n";
    $testno++;
}




print "Modulus 10 sjekk...\n";
for (['1'          => 8],
     ['12'         => 5],
     ['123'        => 0],
     ['1234'       => 4],
     ['12345'      => 5],
     ['1234567'    => 4],
     ['12345678'   => 2],
     ['123456789'  => 7],
     ['1234567890' => 3],
     ['6'          => 7],
     ['66'         => 1],
     ['666'        => 8],
     ['6666'       => 2],
     ['66666'      => 9],
     ) {
    my($siffer, $forventet) = @$_;
    my $m10 = modulus_10($siffer);
    print "modulus_10($siffer) => $m10";
    if ($m10 != $forventet) {
	print " (forventet: $forventet)\n";
	print "not ";
    } else {
	print "\n";
    }
    print "ok $testno\n";
    $testno++;
}

