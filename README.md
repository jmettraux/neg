
# neg

A neg narser.

A silly little exploration project.

It could have been "peg" as in "peg, a peg parser" but that would have been presomptuous, it could have been "leg" as in "leg, a leg larser", but there is already a [leg](http://piumarta.com/software/peg/peg.1.html), so it became "neg" as in "neg, a neg narser". It sounds neg-ative, but whatever, it's just a toy project.


## Ruby PEG libraries

Ruby has many such libraries. Here are three preeminent ones:

* Treetop: <http://treetop.rubyforge.org/>
* Citrus: <http://mjijackson.com/citrus/>
* Parslet: <http://kschiess.github.com/parslet/>

My favourite is Parslet. Neg is born out of the ashes of contribution attempts to Parslet. Studying this great library made me want to implement my own mini PEG library, for the fun of it.

So if you're looking for something robust and battle-tested, something for the long term, stop reading here and use one of the three gems above. IMHO, [Parslet](http://kschiess.github.com/parslet/) stands above for its error reporting.


## expressing a grammar with neg

Here is the classical arithmetic example:

```ruby
  class ArithParser < Neg::Parser

    expression  == operation

    operation   == value + ((`+` | `-` | `*` | `/`) + value) * 0
    value       == parenthese | number
    parenthese  == `(` + expression + `)`
    number      == `-` * -1 + _('0-9') * 1
  end

  tree = ArithParser.parse("1+(2*12)")
```

(Note: this is Ruby code)


## grammar building blocks

```ruby
# leaves

  StringParser
    text == `foreach`

  CharacterParser
    stuff == _             # any character
    stuff == _ * 1         # one or more of any character
    stuff == _("0-9") * 1  # like /[0-9]+/

# composite

  SequenceParser
    sentence == subject + verb + object

  AlternativeParser
    subject == person | animal | place

  # parentheses
    sentence = (person | animal) + verb + (object | (`in ` + place))

# modifiers

  RepetitionParser
    text == `x` * 0       # 0 or more
    text == `x` * 1       # 1 or more
    text == `x` * -1      # 0 or 1
    text == `x` * [2, 4]  # 2, 3 or 4

  LookaheadParser
    x_then_z     == `x` + ~`z`  # presence
    x_then_not_z == `x` + -`z`  # absence

# naming

  NonTerminalParser
    brand == `mazda` | `ford`  # "brand" is the non-terminal
```


## parse output

TODO


## presentations

Neg was published on the 2012-10-06 as it was presented to [Hiroshima.rb](http://hiroshimarb.github.com/).

The \[very dry\] deck of slides that accompanied it can be found at <https://speakerdeck.com/u/jmettraux/p/neg-a-neg-narser>.


## license

MIT (see LICENSE.txt)

