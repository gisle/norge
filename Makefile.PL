require 5.002;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME     => 'No',
	VERSION  => '1.03',
	
	DISTNAME => 'Norge',
 	dist    => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
