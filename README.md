
# neg

A neg narser.

A silly little exploration project.

It could have been "peg" as in "peg, a peg parser" but that would have been presomptuous, it could have been "leg" as in "leg, a leg larser", but that there is already a [leg](http://piumarta.com/software/peg/peg.1.html), so it became "neg" as in "neg, a neg narser". It sounds neg-ative, but whatever, it's just a toy project.


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


## the output of the parser

TODO


## presentations

Neg was published on the 2012-10-06 as it was presented to [Hiroshima.rb](http://hiroshimarb.github.com/).

Here is the \[very dry\] deck of slides that accompanied it:

<script async class="speakerdeck-embed" data-id="506fcaf1240f5100020621e3" data-ratio="1.3333333333333333" src="//speakerdeck.com/assets/embed.js"></script>


## license

MIT (see LICENSE.txt)

