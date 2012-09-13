
require 'spec_helper'


describe Leg::Parser::AlternativeParser do

  class AltParser < Leg::Parser
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

    parser = Class.new(Leg::Parser) do
      text == `x` | `y` | `z`
    end

    text = parser.text

    text.class.should ==
      Leg::Parser::NonTerminalParser
    text.child.children.collect(&:class).should ==
      [ Leg::Parser::StringParser ] * 3
  end
end

