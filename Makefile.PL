require 5.002;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME     => 'No',
	VERSION  => '0.02',
	
	DISTNAME => 'Norge',
 	dist    => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
