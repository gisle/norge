use Test qw(plan ok);
plan tests => 7;

use No::Skatt qw(skatt);

ok skatt(), 0;
ok skatt(year => 2013, lonnsinntekt =>      5_000),          0;
ok skatt(year => 2013, lonnsinntekt =>     50_000),      2_600;
ok skatt(year => 2013, lonnsinntekt =>    500_000),    143_034;
ok skatt(year => 2013, lonnsinntekt =>  5_000_000),  2_658_774;
ok skatt(year => 2013, lonnsinntekt => 50_000_000), 28_218_774;

ok skatt(year => 2013, lonnsinntekt => 1_000_000, kapitalinntekt => 50_000, formue => 1000_000), 402204;
