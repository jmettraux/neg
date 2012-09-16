
require 'spec_helper'


describe Neg::Parser::AlternativeParser do

  class AltParser < Neg::Parser
    text == `x` | `y`
  end

  it 'parses' do

    AltParser.parse('x').should ==
      [ :text, true, [ 0, 1, 1 ], [
        [ nil, true, [ 0, 1, 1 ], 'x' ] ] ]
  end

  it 'parses (2nd alternative succeeds)' do

    AltParser.parse('y').should ==
      [ :text, true, [ 0, 1, 1 ], [
        [ nil, false, [ 0, 1, 1 ], 'expected "x", got "y"' ],
        [ nil, true, [ 0, 1, 1 ], 'y' ] ] ]
  end

  it 'fails gracefully' do

    AltParser.parse('z').should ==
      [ :text, false, [ 0, 1, 1 ], [
        [ nil, false, [ 0, 1, 1 ], 'expected "x", got "z"' ],
        [ nil, false, [ 0, 1, 1 ], 'expected "y", got "z"' ] ] ]
  end

  it 'goes beyond two elements' do

    parser = Class.new(Neg::Parser) do
      text == `x` | `y` | `z`
    end

    text = parser.text

    text.class.should ==
      Neg::Parser::NonTerminalParser
    text.child.children.collect(&:class).should ==
      [ Neg::Parser::StringParser ] * 3
  end
end

