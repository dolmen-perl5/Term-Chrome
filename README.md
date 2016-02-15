# NAME

Term::Chrome - DSL for colors and other terminal chrome

# SYNOPSIS

    use Term::Chrome qw<Red Blue Bold Reset Underline Green color>;
    use feature qw<say>; # Just for this example

    # Base color constant and attribute
    say Red, 'red text', Reset;

    # Composition, using operator overloading
    say Red/Blue+Bold, 'red on blue', Reset;

    # Extended xterm-256 colors
    say color(125) + Underline, 'Purple', Reset;

    # Define your own constants
    use constant Pink => color 213;

    # Use ${} around Chrome expression inside strings
    say "normal ${ Red+Bold } RED ${ +Reset } normal";

    # Extract components
    say( (Red/Blue)->bg, "blue text", (Green+Reset)->flags );

Chromizer: get a closure that applies given chrome before, and `Reset` after
the argument.

    # Get an efficient chromizer
    my $boldifier = \&{ +Bold };
    # Use the chromizer
    say $boldifier->("bold text");

    # Short lived chromizers using color literals:
    say &{+Red}('red');
    say &{ Red/Blue + Bold }('red on blue');
    # Same, but requires perl 5.21.4+
    #say(( Red/Blue + Bold )->('red on blue'));

# DESCRIPTION

`Term::Chrome` is a domain-specific language (DSL) for terminal decoration
(colors and other attributes).

In the current implementation stringification to ANSI sequences for `xterm`
and `xterm-256` is hard-coded (which means it doesn't use the [terminfo(5)](http://man.he.net/man5/terminfo)
database), but this gives optimized (short) strings.

Colors and attributes are exposed as objects that have overloading for
arithmetic operators.

# EXPORTS

## Functions

`color(_0-255_)`

Build a [Term::Chrome](https://metacpan.org/pod/Term::Chrome) object with the given color number. You can use this
constructor to create your own set of color constants.

For example, `color(0)` gives the same result as `Black` (but not the same
object).

## Colors

Each of these function return a Chrome object.

- `Black`: `color 0`
- `Red`: `color 1`
- `Green`: `color 2`
- `Yellow`: `color 3`
- `Blue`: `color 4`
- `Magenta`: `color 5`
- `Cyan`: `color 6`
- `White`: `color 7`

## Decoration flags

The exact rendering of each flag is dependent on how the terminal implements
them. For example `Underline` and `Blink` may do nothing.

- `Bold`
- `Underline`
- `Blink`
- `Reverse`

## Special flags

- `Reset` : reset all colors and flags

# METHODS

Here are the methods on `Term::Chrome` objects:

- `fg`

    Extract the Chrome object of just the foreground color. Maybe `undef`.

- `bg`

    Extract the Chrome object of the just background color. Maybe `undef`.

- `flags`

    Extract a Chrome object of just the decoration flags. Maybe `undef`.

# OVERLOADED OPERATORS

- `/` (mnemonic: "over")

    Conmbine a foreground color (on the left) with a background color.

- `+`

    Add decoration flags (on the right) to colors (on the left).

- `""` (stringification)

    Transform the object into a sting of ANSI sequences. This is
    particularly useful to directly use a Chrome object in a double quoted string.

- `${}` (scalar dereference)

    Same result as `""` (stringification). This operator is overloaded because
    it is convenient to interpolate Chrome expressions in double-quoted strings.

    Examples:

        say "normal ${ +Red } red ${ +Reset }";
        say "normal ${ Red + Bold } red ${ +Reset }";

    Note that you must force expression parsing context when a Chrome constant is
    used alone inside `${ }`: `${ +Red }` or `${ (Red) }` or `${ Red() }`.
    `use strict 'vars';` will detect those cases, but you may miss them in
    one-liners.

- `&{}` (code dereference, or _codulation_)

    Wrap some text with the given chrome and `Reset`.

    Example:

        say Red->("red text");
        # Same result as:
        say Red, "red text", Reset;

    Unfortunately perl had a bug
    ([perl RT#122607](https://rt.perl.org/Ticket/Display.html?id=122607)) that makes this feature not much usable in practice when applied to constants. That bug
    is fixed in perl 5.21.4+.
    On perl < 5.21.4 you have to wrap the chrome constant in a `do {}`:

        say do{ Red }->("red text");

    Codulation can also be used to extract a colorizer sub that will be more
    efficient if you use it multiple times:

        my $redifier = \&{ Red };
        say $redifier->("red text");

# BUGS

See the warnings about `${}` and `&{}` above.

# SEE ALSO

Comments on each modules are opinions of the author.

- [Term::ANSIColor](https://metacpan.org/pod/Term::ANSIColor): the same basic features (and the others should not be in
Term::ANSIColor itself but in an extension), but with an awful API I could never
even consider to use while keeping my sanity.
- [Term::ScreenColor](https://metacpan.org/pod/Term::ScreenColor)
- [PerlIO::via::ANSIColor](https://metacpan.org/pod/PerlIO::via::ANSIColor)
- [AngelPS1](https://metacpan.org/pod/AngelPS1) or [https://github.com/dolmen/angel-PS1](https://github.com/dolmen/angel-PS1): "The Angel's Prompt" is
the project for which `Term::Chrome` has been built. [AngelPS1::Compiler](https://metacpan.org/pod/AngelPS1::Compiler),
the `angel-PS1` compiler has special support for `Term::Chrome` values.

# TRIVIA

Did you know that _chartreuse_ is one of the favorite colors of Larry Wall?

# AUTHOR

Olivier Mengué, [mailto:dolmen@cpan.org](mailto:dolmen@cpan.org)

# COPYRIGHT & LICENSE

Copyright © 2013-2014 Olivier Mengué.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl 5 itself.
