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
