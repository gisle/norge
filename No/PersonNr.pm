package No::PersonNr;

require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK = qw(personnr_ok er_mann er_kvinne fodt_dato);

use Carp qw(croak);
use strict;
use vars qw($VERSION);

$VERSION = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);


=head1 NAME

No::PersonNr - Check Norwegian Social security numbers

=head1 SYNOPSIS

  use No::PersonNr qw(personnr_ok);

  if (personnr_ok($nr)) {
      # ...
  }

=head1 DESCRIPTION

B<This documentation is written in Norwegian.>

Denne modulen kan brukes for � sjekke norske personnummer.  De 2 siste
siffrene i personnummerene er kontrollsiffre og m� stemme overens med
resten for at det skal v�re et gyldig nummer.  Modulen inneholder ogs�
funksjoner for � bestemme personens kj�nn og personens f�dselsdato.

Ingen av rutinene eksporteres implisitt.  Du m� be om dem.  F�lgende
funksjoner er tilgjengelig:

=over 4

=item personnr_ok($nr)

Funksjonen personnr_ok() vil returnere FALSE hvis personnummeret gitt
som argument ikke er gyldig.  Hvis nummeret er gyldig s� vil
funksjonen returnere $nr p� standard form.  Nummeret som gis til
personnr_ok() kan inneholde ' ' eller '-'.

Standard form er her definert som 11 siffer uten noe skilletegn
mellom tallgrupper.

=cut

sub personnr_ok
{
    my($nr,$returndate) = @_;
    return undef unless defined($nr);
    $nr =~ s/[\s\-]+//g;
    return "" if $nr =~ /\D/;
    return "" if length($nr) != 11;
    my @nr = split(//, $nr);

    # Modulo 11 test
    my($vekt);
    for $vekt ([ 3, 7, 6, 1, 8, 9, 4, 5, 2, 1, 0 ],
	       [ 5, 4, 3, 2, 7, 6, 5, 4, 3, 2, 1 ]) {
	my $sum = 0;
	for (0..10) {
	    $sum += $nr[$_] * $vekt->[$_];
 	}
	return "" if $sum % 11;
    }

    # Extract the date part
    my @date = reverse unpack("A2A2A2A3", $nr);
    my $pnr = shift(@date);

    # H-nummer -- hjelpenummer, en virksomhetsintern, unik identifikasjon av
    # en person som ikke har f�dselsnummer/D-nummer eller hvor dette er
    # ukjent.  4 er lagt til tredje siffer.
    $date[1] -= 40 if $date[1] > 40;

    # D-nummer -- For personer som ikke er bosatt i Norge, men som likevel
    # er skatte- og/eller trygdepliktig.  4 er lagt til f�rste siffer.
    $date[2] -= 40 if $date[2] > 40;

    # S� var det det � kjenne igjen hvilket hundre�r som er det riktige.
    #
    #   Individnummer  �r i f�dselsdato  F�dt
    #   500 - 749      > 54              1855 - 1899
    #   000 - 499                        1900 - 1999
    #   500 - 999      < 55              2000 - 2054
    #
    if ($pnr < 500) {
        # ingen tvetydighet; person f�dt 1900 - 1999
        $date[0] += 1900;
    } elsif ($pnr >= 750) {
        # ingen tvetydighet; person f�dt 2000 - 2054
	$date[0] += 2000;
    } else {
        # tvetydig; m� se p� de to sifrene for f�dsels�r
        if ($date[0] > 54) {
            # person f�dt 1855 - 1899
            $date[0] += 1800;
        } else {
            # person f�dt 2000 - 2054
            $date[0] += 2000;
        }
    }
    return "" unless _is_legal_date(@date);

    return $returndate ? join("-", @date) : $nr;
}


sub _is_legal_date
{
    my($y,$m,$d) = @_;
    return if $d < 1;
    return if $m < 1 || $m > 12;

    my $mdays = 31;
    if ($m == 2) {
	$mdays = (($y % 4 == 0) && ($y % 100 != 0)) || ($y % 400 == 0)
	  ? 29 : 28;
    } elsif ($m == 4 || $m == 6 || $m == 9 || $m == 11) {
	$mdays = 30;
    }
    return if $d > $mdays;
    1;
}


=item er_mann($nr)

Vil returnere TRUE hvis $nr tilh�rer en mann.  Rutinen vil croake hvis
nummeret er ugyldig.

=cut

sub er_mann
{
    my $nr = personnr_ok(shift);
    croak "Feil i personnummer" unless $nr;
    substr($nr, 8, 1) % 2;
}


=item er_kvinne($nr)

Vil returnere TRUE hvis $nr tilh�rer en kvinne.  Rutinen vil croake
hvis nummeret er ugyldig.

=cut

sub er_kvinne { !er_mann(@_); }


=item fodt_dato($nr)

Vil returnere personens f�dselsdato p� formen "����-MM-DD".  Rutinen
returnerer C<""> hvis nummeret er ugyldig.

=cut

sub fodt_dato
{
    personnr_ok(shift, 1);
}

1;

=back

=head1 REFERENCES

=over 4

=item [1]

"Hjelpenummer for personer uten kjent f�dselsnummer", Torbj�rn Nystadnes,
Kompetansesenter for IT i helsevesenet AS (KITH).  KITH-rapport,
Rapportnummer 11/98, ISBN 82-7846-051-5, 1998-12-11.

=item [2]

"F�dselsnummeret, oppbygging - kontrollsiffer - l�sning etter �r 2000".
Brosjyre fra Skattedirektoratet.

=item [3]

Skattedirektoratet, Sentralkontoret for folkeregistrering,

=back

=head1 LIMITATIONS

Personnummersystemet h�ndterer kun �rstall fra og med 1855 til og med 2054.

=head1 AUTHORS

Gisle Aas <gisle@aas.no>, Peter J. Acklam <pjacklam@online.no>, Petter
Reinholdtsen <pere@hungry.com>, Hallvard B. Furuseth
<h.b.furuseth@usit.uio.no>.

=cut
