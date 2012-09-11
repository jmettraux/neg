
require 'spec_helper'


describe Leg::Parser do

  describe 'sequence' do

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

  describe 'alternative' do

    class AltParser < Leg::Parser
      text == `x` | `y`
    end

    it 'parses' do

      AltParser.parse('x').should ==
        [ :text, true, [ 0, 1, 1 ], [
          [ nil, true, [ 0, 1, 1 ], 'x' ],
          [ nil, false, [ 1, 1, 2 ], 'expected "y", got ""' ] ] ]
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

  describe 'non-terminal' do

    let(:parser) {
      Class.new(Leg::Parser) do
        text == x | y
        x    == `x`
        y    == `yy` | `y`
      end
    }

    it 'parses' do

      parser.parse('x')[1].should == true
      parser.parse('y')[1].should == true
      parser.parse('yy')[1].should == true
      parser.parse('z')[1].should == false
    end
  end

  describe '.parse' do

    let(:parser) {
      Class.new(Leg::Parser) do
        text == `x`
      end
    }

    it 'raises on unconsumed input' do

      lambda {
        parser.parse('xy')
      }.should raise_error(
        Leg::UnconsumedInputError,
        'remaining: "y"')
    end

    it 'raises on unconsumed input (...)' do

      lambda {
        parser.parse('xyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy')
      }.should raise_error(
        Leg::UnconsumedInputError,
        'remaining: "yyyyyyy..."')
    end
  end
end

