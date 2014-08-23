use strict;
use warnings;

package Term::Chrome;
# ABSTRACT: DSL for colors and other terminal chrome
our $VERSION = '1.000';

# Pre-declare packages
{
    package # no index: private package
        Term::Chrome::Color;
}

use Carp ();

our @CARP_NOT = qw< Term::Chrome::Color >;

# Private constructor for Term::Chrome objects. Lexical, so cross-packages.
# Arguments:
# - class name
# - foreground color
# - background color
# - flags list
my $Chrome = sub (*$$;@)
{
    my ($class, @self) = @_;

    my $fg = $self[0];
    Carp::croak "invalid fg color $fg"
        if defined($fg) && ($fg < 0 || $fg > 255);
    my $bg = $self[1];
    Carp::croak "invalid bg color $bg"
        if defined($bg) && ($bg < 0 || $bg > 255);
    # TODO check flags

    bless \@self, $class
};


# Cache for color objects
my %COLOR_CACHE;

sub color ($)
{
    my $color = shift;
    die "invalid color" if ref $color;
    $COLOR_CACHE{chr($color)} ||=
        $Chrome->(Term::Chrome::Color::, $color, undef);
}


use Exporter 5.57 'import';  # perl 5.8.3

#our @EXPORT_OK;
#BEGIN { our @EXPORT_OK = ('color'); }

{
    my $mk_flag = sub { $Chrome->(__PACKAGE__, undef, undef, $_[0]) };

    # This is a method
    sub flags
    {
        my $self = shift;
        return undef unless $#$self >= 2;
        $Chrome->(__PACKAGE__, undef, undef, @{$self}[2..$#$self])
    }

    my %const = (
        Reset      => $mk_flag->(''),
        ResetFg    => $mk_flag->(39),
        ResetBg    => $mk_flag->(49),
        ResetFlags => $mk_flag->(22),
        Standout   => $mk_flag->(7),
        Underline  => $mk_flag->(4),
        Reverse    => $mk_flag->(7),
        Blink      => $mk_flag->(5),
        Bold       => $mk_flag->(1),

        Black      => color 0,
        Red        => color 1,
        Green      => color 2,
        Yellow     => color 3,
        Blue       => color 4,
        Magenta    => color 5,
        Cyan       => color 6,
        White      => color 7,

        # Larry Wall's favorite color
        # The true 'chartreuse' color from X11 colors is #7fff00
        # The xterm-256 color #118 is near: #87ff00
        Chartreuse => color 118,
    );

    our @EXPORT = ('color', keys %const);

    if ($^V lt v5.16.0) {
        while (my ($name, $value) = each %const) {
            no strict 'refs';
            *$name = sub () { $value };
        }
    } else {
        require constant;
        constant->import(\%const);
    }
}

use overload
    '""' => 'term',
    '+'  => 'plus',
    '${}' => 'deref',
;

sub term
{
    my $self = shift;
    my ($fg, $bg) = @{$self}[0, 1];
    my $r = join(';', @{$self}[2 .. $#$self]);
    if (defined($fg) || defined($bg)) {
        $r .= ';' if @$self > 2;
        if (defined $fg) {
            $r .= $fg < 8 ? (30+$fg) : $fg < 16 ? "9$fg" : "38;5;$fg";
            $r .= ';' if defined $bg;
        }
        $r .= $bg < 8 ? (40+$bg) : $bg < 16 ? "10$bg" : "48;5;$bg" if defined $bg;
    }
    "\e[${r}m"
}

sub clone
{
    bless [ @{$_[0]} ], __PACKAGE__
}

sub plus
{
    my ($self, $other, $swap) = @_;

    die 'invalid value for +' unless $other->isa(__PACKAGE__);

    my @new = @$self;
    $new[0] = $other->[0] if defined $other->[0];
    $new[1] = $other->[1] if defined $other->[1];
    push @new, @{$other}[2 .. $#$other];

    bless \@new, __PACKAGE__
}

sub deref
{
    \("$_[0]")
}

sub fg
{
    my $c = $_[0]->[0];
    defined($c) ? color($c) : undef
}

sub bg
{
    my $c = $_[0]->[1];
    defined($c) ? color($c) : undef
}

package # no index: private package
    Term::Chrome::Color;

our @ISA = (Term::Chrome::);

use overload
    '/'   => 'over',
    # Even if overloading is set in the super class, we have to repeat it for old perls
    (
        $^V ge v5.18.0
        ? ()
        : (
            '""'  => \&Term::Chrome::term,
            '+'   => \&Term::Chrome::plus,
            '${}' => \&Term::Chrome::deref,
        )
    ),
;

sub over
{
    die 'invalid bg color for /' unless ref($_[1]) eq __PACKAGE__;
    $Chrome->(Term::Chrome::, $_[0]->[0], $_[1]->[0])
}

1;
# vim:set et ts=8 sw=4 sts=4:
