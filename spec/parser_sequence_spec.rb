
require 'spec_helper'


describe Neg::Parser::SequenceParser do

  class SeqParser < Neg::Parser
    text == `x` + `y`
  end

  it 'parses' do

    SeqParser.parse('xy').should ==
      [ :text, [ 0, 1, 1 ], true, 'xy', [] ]
  end

  it 'fails gracefully' do

    SeqParser.parse('xx').should ==
      [ :text, [ 0, 1, 1 ], false, nil, [
        [ nil, [ 0, 1, 1 ], true, 'x', [] ],
        [ nil, [ 1, 1, 2 ], false, 'expected "y", got "x"', [] ] ] ]
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
        [ 0, 1, 1 ],
        true,
        nil,
        [ [ :pool, [ 0, 1, 1 ], true, "pool", [] ] ] ]
  end
end

