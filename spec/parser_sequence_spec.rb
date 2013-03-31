
require 'spec_helper'


describe Neg::Parser::SequenceParser do

  class SeqParser < Neg::Parser
    text == `x` + `y`
  end

  it 'parses' do

    SeqParser.parse('xy').should ==
      [ :text, 0, true, 'xy', [] ]
  end

  it 'fails gracefully' do

    SeqParser.parse('xx').should ==
      [ :text, 0, false, nil, [
        [ nil, 0, true, 'x', [] ],
        [ nil, 1, false, 'expected "y", got "x"', [] ] ] ]
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
        0,
        true,
        nil,
        [ [ :pool, 0, true, 'pool', [] ] ] ]
  end

  it 'does not concat non-terminal results' do

    parser = Class.new(Neg::Parser) do
      data == num + `+` + num
      num == _('0-9') * 1
    end

    parser.parse('12+10').should ==
      [ :data,
        0,
        true,
        nil, [
          [ :num, 0, true, '12', [] ],
          [ nil, 2, true, '+', [] ],
          [ :num, 3, true, '10', [] ] ] ]
  end
end

