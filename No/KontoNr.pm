package No::KontoNr;

require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK = qw(kontonr_ok modulus_10);

$VERSION = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);

use strict;

sub kontonr_ok {
    my $nr = shift || return 0;
    $nr =~ s/[ \.]//g;  # det er ok med mellomrom og punktum i nummeret

    # Først et par trivielle sjekker
    return 0 unless length($nr) == 11;
    return 0 if $nr =~ /\D/;

    # Siste siffer er kontrollsiffer, plukk det av
    $nr =~ s/(\d)$//;
    my $kontroll = $1; 

    my $sum = 0;
    my $i = 0;
    my $vekt;
    for $vekt (qw(5 4 3 2 7 6 5 4 3 2)) {
        $sum += substr($nr, $i++, 1) * $vekt;
    }
    my $k = 11 - ($sum % 11);
    return 0 if $k == 10;  # disse er alltid ulovlige
    $k = 0 if $k == 11;
    return 0 if $k != $kontroll;
    return $nr;
}

sub modulus_10
{
    my $tall = shift;
    $tall =~ s/[^\d]//g;
    my $siffersum = 0;
    my $vekt = 2;
    my $siffer;
    foreach $siffer (reverse split(//, $tall)) {
        my $produkt = $siffer * $vekt;
        # print "$siffer×$vekt=$produkt\n";
        while ($produkt >= 10) {
            $siffersum++;
            $produkt -= 10;
        }
        $siffersum += $produkt;
        $vekt = 3 - $vekt;
    }
    # print "SUM=$siffersum\n";
    (- $siffersum) % 10;
}

1;
