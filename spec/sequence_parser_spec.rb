
require 'spec_helper'


describe Leg::Parser::SequenceParser do

  class SeqParser < Leg::Parser
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

    parser = Class.new(Leg::Parser) do
      text == `x` + `y` + `z`
    end

    text = parser.text

    text.class.should ==
      Leg::Parser::NonTerminalParser
    text.child.children.collect(&:class).should ==
      [ Leg::Parser::StringParser ] * 3
  end
end

