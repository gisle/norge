$|=1;

print "1..3\n";

use No::Sort;

@ord = ("fulg", "fisk", "æ", "å", "A", "Æ", "månerelé", "idé",
"ide", "ø", "Ø", "Å", "Ål", "Ålesund", "måse", "ålesünd", "ö", "ô",
"o", "grus", "idf", "Ö", "ä", "maskere", "4kløver");

@a = no_sort @ord;

# while testing, we want debug output on STDOUT
open(STDERR, ">&STDOUT");

$No::Sort::DEBUG=1;
@b = no_sort @ord;

print "not " unless "@a" eq "@b";
print "ok 1\n";

print "----\n";
print join("/", @a), "\n";

print "not " unless join("/",@a) eq "4kløver/A/fisk/fulg/grus/ide/idé/idf/maskere/månerelé/måse/o/ô/Æ/ä/æ/Ö/Ø/ö/ø/Å/å/Ål/Ålesund/ålesünd";
print "ok 2\n";


sub my_xfrm {
    my $word = shift;
    $word =~ s/A[aA]/Å/g;
    $word =~ s/aa/å/g;
    No::Sort::no_xfrm($word);
}

@names = ("Aas", "Asheim", "Andersen", "Haakon", "Hansen", "Østerud",
"Åsheim", "Aanonsen", "Åmås");

@a = no_sort \&my_xfrm, @names;

print "not " unless join("/",@a) eq "Andersen/Asheim/Hansen/Haakon/Østerud/Åmås/Aanonsen/Aas/Åsheim";
print "ok 3\n";

