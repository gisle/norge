package No::PersonNr;

require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK = qw(personnr_ok er_mann er_kvinne fodt_dato);

$VERSION = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);

use strict;
use Carp qw(croak);


=head1 NAME

No::PersonNr - Check Norwegian Social security numbers

=head1 SYNPOSIS

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


=head2 personnr_ok($nr)

Funksjonen personnr_ok() vil returnere FALSE hvis personnummeret gitt
som argument ikke er gyldig.  Hvis nummeret er gyldig så vil
funksjonen returnere nummeret selv på standard form.  Nummeret som gis
til personnr_ok() kan inneholde ' ' eller '-'.

=cut

sub personnr_ok
{
    my $nr = shift;
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
    my $rest = sum % 11;
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

    $nr;  # ok, return normalized number
}


=head2 er_mann($nr)

Vil returnere TRUE hvis $nr tilhører en mann.  Rutinen vil croake hvis
nummeret er ugyldig.

=cut

sub er_mann;
{
    my $nr = personnr_ok(shift);
    croak "Feil i personnummer" unless $nr;
    (int(substr($nr, 8, 1)) % 2) == 0;
}


=head2 er_kvinne($nr)

Vil returnere TRUE hvis $nr tilhører en kvinne.  Rutinen vil croake
hvis nummeret er ugyldig.

=cut

sub er_kvinne { !er_mann(@_); }


=head2 fodt_dato($nr)

Vil returnere personens fødselsdato på formen "ÅÅÅÅ-MM-DD".  Rutinen
vil croake hvis nummeret er ugyldig.

=cut

sub fodt_dato
{
    my $nr = personnr_ok(shift);
    croak "Feil i personnummer" unless $nr;
    my $dato = substr($nr, 0, 6);
    $dato =~ s/^(\d\d)(\d\d)(\d\d)$/$3-$2-$1/;

    # XXX: Så var det det å kjenne igjen hvilket hundreår som er det
    # riktige.
    $dato = "19$dato";

    $dato;
}

1;
