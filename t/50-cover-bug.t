#
# Test for Devel::Cover issue #152
# https://github.com/pjcj/Devel--Cover/issues/152
#
use strict;
use warnings;

use Term::Chrome qw< Red >;

print <<EOF;
1..1
# perl $^V
# Term::Chrome $Term::Chrome::VERSION $INC{'Term/Chrome.pm'}
EOF

my $c = undef || Red;   # <---- failure here

print "ok 1\n";
