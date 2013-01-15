
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

    operator    == `+` | `-` | `*` | `/`
    operation   == value + (operator + value) * 0
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

  NonTerminalParser (name is omitted in output parse tree)
    _operator == `+` | `*` | `-` | `/`

  Embedded naming (here "operator")
    operation == number + (`+` | `-`)["operator"] + number
```


## parser output

Without a translator, the parser outputs a raw parse tree, something like:

```ruby
[ :json,
  [ 0, 1, 1 ],
  true,
  nil,
  [ [ :spaces?, [ 0, 1, 1 ], true, '', [] ],
    [ :value, [ 0, 1, 1 ], true, nil, [
      [ :bfalse, [ 0, 1, 1 ], true, 'false', [] ] ] ],
    [ :spaces?, [ 5, 1, 6 ], true, '', [] ] ] ]
```

It's a nested assemblage of result nodes.

```ruby
[ rule_name, [ offset, line, column ], success?, result, children ]
  #
  # for example
[ :bfalse, [ 0, 1, 1 ], true, 'false', [] ]
```

In case of successful parsing, the succes? == false also get all pruned. In case of failed parsing, they are left in the output parse tree.

A translator turns a raw parse tree into some final result. Look below and at the JSON parser sample in the specs for more information. If the parse failed and a translator is present, a ParseError is raised.


## parser + translator

It's OK to stuff the translator inside of the parser:

```ruby
class CompactArithParser < Neg::Parser

  parser do

    expression  == operation

    operator    == `+` | `-` | `*` | `/`
    operation   == value + (operator + value) * 0
    value       == parenthese | number
    parenthese  == `(` + expression + `)`
    number      == `-` * -1 + _('0-9') * 1
  end

  translator do

    on(:number)    { |n| n.result.to_i }
    on(:operator)  { |n| n.result }
    on(:value)     { |n| n.results.first }

    on(:expression) { |n|
      results = n.results.flatten(2)
      results.size == 1 ? results.first : results
    }
  end
end

CompactArithParser.parse("1+2+3")
  # => [ 1, '+', 2, '+', 3 ]
```

As said above, when a translator is present and the parsing fails (before the translator kicks in), a ParseError is raised, with fancy methods to navigate the failed parse tree.


## presentations

Neg was published on the 2012-10-06 as it was presented to [Hiroshima.rb](http://hiroshimarb.github.com/).

The \[very dry\] deck of slides that accompanied it can be found at <https://speakerdeck.com/u/jmettraux/p/neg-a-neg-narser>.


## links

* source: <https://github.com/jmettraux/neg>
* issues: <https://github.com/jmettraux/neg/issues>
* irc: freenode.net #ruote


## license

MIT (see LICENSE.txt)

