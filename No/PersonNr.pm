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

Denne modulen kan brukes for å sjekke norske personnummer.  De 2 siste
siffrene i personnummerene er kontrollsiffre og må stemme overens med
resten for at det skal være et gyldig nummer.  Modulen inneholder også
funksjoner for å bestemme personens kjønn og personens fødselsdato.

Ingen av rutinene eksporteres implisitt.  Du må be om dem.

=head1 FUNCTIONS

=head2 personnr_ok($nr)

Funksjonen personnr_ok() vil returnere FALSE hvis personnummeret gitt
som argument ikke er gyldig.  Hvis nummeret er gyldig så vil
funksjonen returnere $nr på standard form.  Nummeret som gis til
personnr_ok() kan inneholde ' ' eller '-'.

=cut

sub personnr_ok
{
    my($nr,$returndate) = @_;
    return undef unless defined($nr);
    $nr =~ s/[\s\-]+//g;
    return 0 if $nr =~ /\D/;
    return 0 if length($nr) != 11;
    my @nr = split(//, $nr);

    # Modulo 11 test
    my $sum = $nr[8]*2 +
              $nr[7]*5 + $nr[6]*4 +
              $nr[5]*9 + $nr[4]*8 +
              $nr[3]*1 + $nr[2]*6 +
              $nr[1]*7 + $nr[0]*3;
    my $rest = $sum % 11;
    return 0 if $rest == 1;
    if ($rest == 0) {
	return 0 if $rest != $nr[9];
    } else {
	return 0 if 11 - $rest != $nr[9];
    }

    $sum = $nr[9]*2 + $nr[8]*3 +
           $nr[7]*4 + $nr[6]*5 +
           $nr[5]*6 + $nr[4]*7 +
           $nr[3]*2 + $nr[2]*3 +
	   $nr[1]*4 + $nr[0]*5;
    $rest = $sum % 11;
    return 0 if $rest == 1;
    if ($rest == 0) {
	return 0 if $rest != $nr[10];
    } else {
	return 0 if 11 - $rest != $nr[10];
    }

    # Extract the date part
    my @date = reverse unpack("A2A2A2A3", $nr);
    my $pnr = shift(@date);
 
    # B-nummer -- midlertidig (max 6 mnd) personnr
    $date[2] -= 30 if $date[2] > 40;

    # Så var det det å kjenne igjen hvilket hundreår som er det riktige.
    # Dette er implementert etter et ikke nødvendigvis troverdig rykte...
    if ($pnr < 500) {
        $date[0] += 1900;
    } elsif ($pnr < 750) {
	$date[0] += 1800;
    } else {
	$date[0] += 2000;
    }
    return 0 unless _is_legal_date(@date);

    return $returndate ? join("-", @date) : $nr;
}


sub _is_legal_date
{
    my($y,$m,$d) = @_;
    return undef if $d < 1;
    return undef if $m < 1 || $m > 12;

    my $mdays = 31;
    if ($m == 2) {
	$mdays = (($y % 4 == 0) && ($y % 100 != 0)) || ($y % 400 == 0)
	  ? 29 : 28;
    } elsif ($m == 4 || $m == 6 || $m == 9 || $m == 11) {
	$mdays = 30;
    }
    return undef if $d > $mdays;
    1;
}


=head2 er_mann($nr)

Vil returnere TRUE hvis $nr tilhører en mann.  Rutinen vil croake hvis
nummeret er ugyldig.

=cut

sub er_mann
{
    my $nr = personnr_ok(shift);
    croak "Feil i personnummer" unless $nr;
    (int(substr($nr, 8, 1)) % 2) != 0;
}


=head2 er_kvinne($nr)

Vil returnere TRUE hvis $nr tilhører en kvinne.  Rutinen vil croake
hvis nummeret er ugyldig.

=cut

sub er_kvinne { !er_mann(@_); }


=head2 fodt_dato($nr)

Vil returnere personens fødselsdato på formen "ÅÅÅÅ-MM-DD".  Rutinen
returnerer I<undef> hvis nummeret er ugyldig.

=cut

sub fodt_dato
{
    my $dato = personnr_ok(shift, 1);
    return undef unless $dato;
    $dato;
}

1;

=head1 BUGS

Takler ikke fødselsdatoer før år 1900 og etter år 2000.  Hvis noen kan
fortelle meg hva algoritmen er så ville jeg være takknemlig.

=head1 AUTHOR

Gisle Aas <aas@sn.no>

=cut
