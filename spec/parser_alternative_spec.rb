
require 'spec_helper'


describe Neg::Parser::AlternativeParser do

  class AltParser < Neg::Parser
    text == `x` | `y`
  end

  it 'parses' do

    AltParser.parse('x').should ==
      [ :text, [ 0, 1, 1 ], true, [
        [ nil, [ 0, 1, 1 ], true, 'x' ] ] ]
  end

  it 'parses (2nd alternative succeeds)' do

    AltParser.parse('y').should ==
      [ :text, [ 0, 1, 1 ], true, [
        [ nil, [ 0, 1, 1 ], false, 'expected "x", got "y"' ],
        [ nil, [ 0, 1, 1 ], true, 'y' ] ] ]
  end

  it 'fails gracefully' do

    AltParser.parse('z').should ==
      [ :text, [ 0, 1, 1 ], false, [
        [ nil, [ 0, 1, 1 ], false, 'expected "x", got "z"' ],
        [ nil, [ 0, 1, 1 ], false, 'expected "y", got "z"' ] ] ]
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

