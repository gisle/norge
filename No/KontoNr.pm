package No::KontoNr;

require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK = qw(kontonr_ok kredittkortnr_ok
		nok_f
                mod_11 mod_10);

use strict;
use vars qw($VERSION);
$VERSION = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);

=head1 NAME

No::KontoNr - Check Norwegian bank account numbers

=head1 SYNPOSIS

  use No::KontoNr qw(kontonr_ok);

  if (personnr_ok($nr)) {
      # ...
  }

=head1 DESCRIPTION

B<This documentation is written in Norwegian.>

Denne modulen kan brukes for � sjekke norske bankontonumre.  Det siste
sifferet i et banknummer er kontrollsiffer og m� stemme overens med
resten for at det skal v�re et gyldig nummer.

Modulen inneholder ogs� funksjoner for � regne ut modulus 10 og
modulus 11 kontrollsiffer.  Disse algoritmene brukes blandt annet hvis
du vil generere KID n�r du skal fylle ut giroblanketter.  De finnes
ogs� en fuksjon som kan brukes for � formatere kronebel�p.

Ingen av rutinene eksporteres implisitt.  Du m� be om dem.

=head1 FUNCTIONS


=head2 kontonr_ok($nr)

Funksjonen kontonr_ok() vil returnere FALSE hvis kontonummeret gitt
som argument ikke er gyldig.  Hvis nummeret er gyldig s� vil
funksjonen returnere $nr p� standard form.  Nummeret som gis
til kontonr_ok() kan inneholde blanke eller punktumer.

=cut

sub kontonr_ok
{
    my $nr = shift || return 0;
    $nr =~ s/[ \.]//g;  # det er ok med mellomrom og punktum i nummeret

    # F�rst et par trivielle sjekker
    return 0 unless length($nr) == 11;
    return 0 if $nr =~ /\D/;

    # Siste siffer er kontrollsiffer, plukk det av
    my $last  = chop($nr);
    my $check = mod_11($nr);
    return 0 if !defined($check) || $check != $last;
    return $nr;
}

=head2 kredittkortnr_ok($nr)

Funksjonen kredittkortnr_ok() vil returnere FALSE hvis
kredittkortnummeret gitt som argument ikke er gyldig.  Hvis nummeret
er gyldig s� vil funksjonen returnere kortselskapets navn.  Nummeret
som gis til kredittkortnr_ok() kan inneholde blanke eller punktumer.

=cut

sub kredittkortnr_ok
{
    my $nr = shift || return 0;
    $nr =~ s/[ \.]//g;  # det er ok med mellomrom og punktum i nummeret
    return 0 if $nr =~ /\D/;

    # Basert p� http://www.websitter.com/cardtype.html
    my $type;
    if ($nr =~ /^5[1-5]/) {
	$type = "MasterCard";
	return 0 if length($nr) != 16;
    } elsif ($nr =~ /^4/) {
	$type = "VISA";
	return 0 if length($nr) != 13 and length($nr) != 16;
    } elsif ($nr =~ /^3[47]/) {
	$type = "American Express";
	return 0 if length($nr) != 15;
    } elsif ($nr =~ /^30[0-5]/ || $nr =~ /^3[68]/) {
	$type = "Diners Club";
	return 0 if length($nr) != 14;
    } elsif ($nr =~ /^6011/) {
	$type = "Discover";
	return 0 if length($nr) != 16;
    } else {
	return 0;
    }

    # Siste siffer er kontrollsiffer
    my $last  = chop($nr);
    return 0 if $last != mod_10($nr);
    return $type;
}


=head2 nok_f($tall)

Denne funksjonen vil formatere tall p� formen:

     300,50
   4.300,-

Det skulle passe bra n�r man skal skrive ut kronebel�p.  �rebel�pet
"00" byttes ut med strengen "- ", dvs. at tallene laines opp korrekt
hvis du h�yrejusterer dem.

=cut

sub nok_f
{
    my $kr = sprintf "%.2f", shift;
    $kr =~ s/\.(\d\d)$/,$1/;
    $kr =~ s/,00$/,- /;
    1 while $kr =~ s/(\d)(\d\d\d)(?=[.,])/$1.$2/;
    $kr;
}


=head2 mod_10($tall)

Denne funksjonen regner ut modulus 10 kontrollsifferet til tallet gitt
som argument.  Hvis argumentet inneholder tegn som ikke er siffer s�
ignoreres de.

Modulus 10 algoritmen benyttes blandt annet for � generere
kontrollsiffer til de fleste internasjonale kredittkortnummer.

=cut

sub mod_10
{
    my $digits = shift;
    my $sum = 0;  # which we subtract from :-)
    my $factor = 2;
    my $s;
    foreach $s (reverse ($digits =~ /(\d)/g)) {
        my $p = $s * $factor;
        if ($p >= 10) {
            $sum--;
            $p -= 10;
        }
        $sum -= $p;
        $factor = 3 - $factor;  # alternates between 2 and 1
    }
    $sum % 10;
}


=head2 mod_11($tall)

Denne funksjonen regner ut modulus 11 kontrollsifferet til tallet gitt
som argument.  Hvis argumentet inneholder tegn som ikke er siffer s�
ignoreres de.  N�r denne algoritmen benyttes s� kan det v�re tall som
det ikke finnes noe gyldig kontrollsiffer for, og da vil mod_11()
returnere verdien I<undef>.

Modulus 11 algoritmen benyttes blandt annet for � generere
kontrollsiffer til norske bankkontonummer.

=cut

sub mod_11
{
    my @digits = reverse (shift =~ /(\d)/g);
    my @factors = (2..7) x ((@digits-1)/6+1);
    my $sum = 0;
    $sum += shift(@digits) * shift(@factors) while @digits;
    my $k = 11 - ($sum % 11);
    if ($k > 9) {
	return undef if $k == 10;
	return 0;
    }
    $k;
}

1;

=head1 SEE ALSO

L<Business::CreditCard>

=head1 AUTHOR

Gisle Aas <aas@sn.no>

=cut

