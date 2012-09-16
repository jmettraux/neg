
require 'spec_helper'


describe Neg::Parser::SequenceParser do

  class SeqParser < Neg::Parser
    text == `x` + `y`
  end

  it 'parses' do

    SeqParser.parse('xy').should ==
      [ :text, true, [ 0, 1, 1 ], [
        [ nil, true, [ 0, 1, 1 ], 'x' ],
        [ nil, true, [ 1, 1, 2 ], 'y' ] ] ]
  end

  it 'fails gracefully' do

    SeqParser.parse('xx').should ==
      [ :text, false, [ 0, 1, 1 ], [
        [ nil, true, [ 0, 1, 1 ], 'x' ],
        [ nil, false, [ 1, 1, 2 ], 'expected "y", got "x"' ] ] ]
  end

  it 'goes beyond two elements' do

    parser = Class.new(Neg::Parser) do
      text == `x` + `y` + `z`
    end

    text = parser.text

    text.class.should ==
      Neg::Parser::NonTerminalParser
    text.child.children.collect(&:class).should ==
      [ Neg::Parser::StringParser ] * 3
  end

  it 'backtracks correctly' do

    parser = Class.new(Neg::Parser) do
      word    == poodle | pool
      poodle  == `poo` + `dle`
      pool    == `poo` + `l`
    end

    parser.parse('pool').should ==
      [ :word,
        true,
        [ 0, 1, 1 ],
        [ [ :poodle,
            false,
            [ 0, 1, 1 ],
            [ [ nil, true, [ 0, 1, 1 ], "poo" ],
              [ nil, false, [ 3, 1, 4 ], "expected \"dle\", got \"l\"" ] ] ],
          [ :pool,
            true,
            [ 0, 1, 1],
            [ [ nil, true, [ 0, 1, 1 ], "poo" ],
              [ nil, true, [ 3, 1, 4 ], "l" ] ] ] ] ]
  end
end

