#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark ':all';

use lib 'lib';
use Term::Chrome;
use Term::ANSIColor qw(colored BOLD RED ON_BLUE RESET YELLOW ON_MAGENTA);

my $s = 'a' x 50;

my %bench = (
    'Chrome normal' => sub {
	join('', Yellow / Magenta, "Yellow on magenta $s", Reset)
    },
    'Chrome CODEREF' => sub {
	&{ Yellow / Magenta }("Yellow on magenta $s")
    },
    'Chrome cached' => do {
	my $yellow_on_magenta = \&{ Yellow / Magenta };
	sub {
	    $yellow_on_magenta->("Yellow on magenta $s")
	}
    },
    'ANSIColor colored' => sub {
	colored(['yellow on_magenta'], "Yellow on magenta $s")
    },
    'ANSIColor constants' => sub {
	join('', YELLOW ON_MAGENTA "Yellow on magenta $s", RESET)
    },
    'ANSIColor autoreset' => sub {
	local $Term::ANSIColor::AUTORESET = 1;
	YELLOW ON_MAGENTA "Yellow on magenta $s"
    },
);

my $Redifier = \&{+Red};
for my $name (keys %bench) {
    my $result = $bench{$name}->();
    $result =~ s/\e(\[.*?[a-zA-Z])/$Redifier->("\\e$1")/ge;
    printf "%s:\n%s\n", $name, $result
}
cmpthese(2000000, \%bench);

%bench = (
    'Chrome constants' => sub {
	join('', Red / Blue + Bold, "Bold red on blue.", Reset)
    },
    'ANSIColor constants' => sub {
	join('', RED BOLD ON_BLUE "Bold red on blue.", RESET)
    },
);
print $_->(), "\n" for values %bench;
cmpthese(2000000, \%bench);

