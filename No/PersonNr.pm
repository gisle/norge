package No::PersonNr;

require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK = qw(personnr_ok er_mann er_kvinne fodt_dato);

$VERSION = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);

use strict;

sub personnr_ok
{
    die "NYI";
}

sub er_mann;
{
    die "NYI";
}

sub er_kvinne { !er_mann(@_); }

sub fodt_dato
{
    die "NYI";
}

1;
__END__

bool fnr_ok(char *fdato, char *pnr)
{
   char fnr[12], *c;
   int sum, rest;

   strcpy(fnr, datosiffer(fdato));
   strcat(fnr, pnr);

   /* gjør det om til ordentlige tall */
   for (c = fnr; *c; c++)
      *c -= '0';

   /* Modulo 11 test */
   sum = fnr[8]*2 + fnr[7]*5 + fnr[6]*4 +
         fnr[5]*9 + fnr[4]*8 + fnr[3]*1 + fnr[2]*6 +
         fnr[1]*7 + fnr[0]*3;
   rest = sum % 11;
   if (rest == 1) return FALSE;
   if (rest == 0) {
      if (rest != fnr[9]) return FALSE;
   } else {
      if (11 - rest != fnr[9]) return FALSE;
   }

   sum = fnr[9]*2 + fnr[8]*3 + fnr[7]*4 + fnr[6]*5 +
         fnr[5]*6 + fnr[4]*7 + fnr[3]*2 + fnr[2]*3 +
         fnr[1]*4 + fnr[0]*5;
   rest = sum % 11;
   if (rest == 1) return FALSE;
   if (rest == 0) {
      if (rest != fnr[10]) return FALSE;
   } else {
      if (11 - rest != fnr[10]) return FALSE;
   }

   return TRUE;
}
