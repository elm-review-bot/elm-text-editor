module Strings exposing (intro)


intro : String
intro =
    """
## I

![Hummingbird::left](http://noteimages.s3.amazonaws.com/jxxcarlson/hummingbird2.jpg)
This project
grew out of the need to have a
pure Elm Markdown parser-renderer.


This project is a work in progress: there is more
 to do make it adhere as closely as
possible to the CommonMark spec and to root out
the bugs and shortcomings in the user interface
design.  Please write me at
jxxcarlson@gmail.com with comments and bug
reports, or (better yet) post an issue on the
[GitHub repo](https://github.com/jxxcarlson/elm-markdown).

For installation, see the notes
at the end. This Markdown package
is written in pure Elm. It uses MathJax.js
to render math formulas.  New in this release
is syntax highlighting using
[pablohirafuji/elm-syntax-highlight](https://package.elm-lang.org/packages/pablohirafuji/elm-syntax-highlight/latest/).
Language support at this time: elm,
javascript, xml, css, python, sql, json.

## Demo

Below we illustrate some typical Markdown
elements: images, links, headings, etc.

![Hummingbird](http://noteimages.s3.amazonaws.com/jxxcarlson/hummingbird2.jpg)
Hummingbird (Meditation)

Link: [New York Times](http://nytimes.com)

Text styles: **bold** *italic* ~~strike it out~~



## Code

He said that `a := 0` is an initialization
statement.

```python
# Partial sum of the harmonic series:

sum = 0
for n in range(1..100):
  sum = sum + 1.0/n
sum
```

## Verbatim and Tables (Extensions)

A verbatim block begins and ends
with four tick marks. It is just
like a code block, except that there is no
syntax highlighting.  Verbatim blocks
are an extension of normal Markdown.

````
Verbatim text has many uses:

   Element    |    Z
   --------------------
   Altium     |    4/5
   Brazilium  |    7/5
   Certium    |    9/5
````

But better is to use Markdown tables:

|  Element  | Symbol |  Z | A |
| Hydrogen  | H      |  1 | 1.008   |
| Helium    | He     |  2 |  4.0026 |
| Lithium   | Li     |  3 |  6.94   |
| Beryllium | Be     |  4 |  9.0122 |
| Boron     | B      |  5 | 10.81   |
| Carbon    | C      |  6 | 12.011  |
| Nitrogen  | N      |  7 | 14.007  |
| Oxygen    | O      |  8 | 15.999  |
| Flourine  | F      |  9 | 18.998  |
| Neon      | Ne     | 10 | 20.180  |


## Lists

Indent by four spaces for each level.  List items
are separated by blank lines.

- Solids

    - Iron *(metal)*

        - Iron disulfide (Pyrite): $FeS_2$, crystalline

        - Iron(II) sulfed $FeS$, not stable, amorphous

    - Selenium *(use for solar cells)*

- Liquids

    - Alcohol *(careful!)*

    - Water *(Ok to drink)*


## Quotations


Quotations are offset:

> Four score and seven years ago our
fathers brought forth on this continent,
a new nation, conceived in Liberty,
and dedicated to the proposition
that all men are created equal.

> Now we are engaged in a great c
ivil war, testing whether that
nation, or any nation so
conceived and so dedicated,
can long endure. We are met o
In a great battle-field of that war.
We have come to dedicate a portion
of that field, as a final resting
place for those who here gave their
lives that that nation might live.
It is altogether fitting and proper
that we should do this.

> But, in a larger sense, we can not
dedicate — we can not consecrate —
we can not hallow—this ground. The brave men,
living and dead, who struggled here,
have consecrated it, far above our poor
power to add or detract. The world will
little note, nor long remember what we say
here, but it can never forget what they d
id here. It is for us the living, rather,
to be dedicated here to the unfinished
work which they who fought here have thus
far so nobly advanced. It is rather for
us to be here dedicated to the great task
remaining before us—that from these
honored dead we take increased devotion
to that cause for which they gave the
last full measure of devotion—that we
here highly resolve that these dead
shall not have died in vain—that
this nation, under God, shall have
a new birth of freedom—and that
government of the people, by the people,
for the people, shall not perish
from the earth.

— Abraham Lincoln, *Gettysbug Address*

## Poetry (Extension)

Poetry blocks, an extension of normal Markdown,
 begin with ">>"; line endings are respected.

>> Twas brillig, and the slithy toves
Did gyre and gimble in the wabe:
All mimsy were the borogoves,
And the mome raths outgrabe.

>> Beware the Jabberwock, my son!
The jaws that bite, the claws that catch!
Beware the Jubjub bird, and shun
The frumious Bandersnatch!


Etcetera!

___


NOTE: this Markdown implementation is
an option for writing documents on
[knode.io](https://knode.io).
Knode also offers MiniLaTeX,
a web-friendly subset of TeX/LaTex.
To see how it works without a sign-in, please
see [demo.minilatex.app](https://demo.minilatex.app).


___

## Installation


To compile, use

```elm
elm make --output=Main.js
```

Then open `index.html` to run the app.


"""
