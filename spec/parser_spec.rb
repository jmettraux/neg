
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

  describe 'using parentheses' do

    it 'influences precedence' do

      parser = Class.new(Leg::Parser) do
        t0 == `x` + `y` | `z`
        t1 == (`x` | `y`) + `z`
      end

      parser.t0.to_s.should == 't0 == ((`x` + `y`) | `z`)'
      parser.t1.to_s.should == 't1 == ((`x` | `y`) + `z`)'
    end
  end

  describe 'naming with > "name"' do

    let(:parser) {
      Class.new(Leg::Parser) do
        transportation ==
          (`car` | `bus`)['vehicle'] +
          `_` +
          (`cluj` | `split`)['city']
      end
    }

    it 'is rendered differently' do

      parser.to_s.strip.should == %q{
:
  transportation == ((`car` | `bus`)["vehicle"] + `_` + (`cluj` | `split`)["city"])
  root: transportation
      }.strip
    end

    it 'sets the name in the result' do

      pp parser.parse('car_cluj')
      parser.parse('car_cluj').should ==
        :x
    end
  end

  describe 'non-terminal' do

    let(:parser) {
      Class.new(Leg::Parser) do
        text == x | z
        x    == `x`
        z    == `zz` | `z`
      end
    }

    it 'parses' do

      parser.parse('x')[1].should == true
      parser.parse('z')[1].should == true
      parser.parse('zz')[1].should == true
      parser.parse('y')[1].should == false
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

