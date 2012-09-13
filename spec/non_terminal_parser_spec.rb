
require 'spec_helper'


describe Leg::Parser::NonTerminalParser do

  context 'name == ...' do

    it 'parses' do

      parser = Class.new(Leg::Parser) do
        text == x | z
        x    == `x`
        z    == `zz` | `z`
      end

      parser.parse('x')[1].should == true
      parser.parse('z')[1].should == true
      parser.parse('zz')[1].should == true
      parser.parse('y')[1].should == false
    end

    it 'sets its name in the result (as a Symbol)' do

      parser = Class.new(Leg::Parser) do
        x == `x` | `X` | `xx`
      end

      parser.parse('X').should ==
        [ :x, true, [ 0, 1, 1 ], [
          [ nil, false, [ 0, 1, 1 ], "expected \"x\", got \"X\"" ],
          [ nil, true, [ 0, 1, 1 ], "X" ] ] ]
    end
  end

  context '... > "name"' do

    let(:parser) {
      Class.new(Leg::Parser) do
        transportation ==
          (`car` | `bus`)['vehicle'] +
          `_` +
          (`cluj` | `split`)['city']
      end
    }

    it 'is rendered as []' do

      parser.to_s.strip.should == %q{
:
  transportation == ((`car` | `bus`)["vehicle"] + `_` + (`cluj` | `split`)["city"])
  root: transportation
      }.strip
    end

    it 'sets the name (as a string) in the result' do

      parser.parse('car_cluj').should ==
        [ :transportation,
          true,
          [ 0, 1, 1],
          [ [ 'vehicle', true, [ 0, 1, 1 ], [ [ nil, true, [ 0, 1, 1 ], 'car' ] ] ],
          [ nil, true, [ 3, 1, 4 ], '_'],
          [ 'city', true, [ 4, 1, 5 ], [ [ nil, true, [ 4, 1, 5 ], 'cluj' ] ] ] ] ]
    end
  end
end

