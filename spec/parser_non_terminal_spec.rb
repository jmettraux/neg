
require 'spec_helper'


describe Neg::Parser::NonTerminalParser do

  context 'name == ...' do

    it 'parses' do

      parser = Class.new(Neg::Parser) do
        text == x | z
        x    == `x`
        z    == `zz` | `z`
      end

      parser.parse('x')[2].should == true
      parser.parse('z')[2].should == true
      parser.parse('zz')[2].should == true
      parser.parse('y')[2].should == false
    end

    it 'sets its name in the result (as a Symbol)' do

      parser = Class.new(Neg::Parser) do
        x == `x` | `X` | `xx`
      end

      parser.parse('X').should ==
        [ :x, [ 0, 1, 1 ], true, nil, [
          [ nil, [ 0, 1, 1 ], false, "expected \"x\", got \"X\"", [] ],
          [ nil, [ 0, 1, 1 ], true, "X", [] ] ] ]
    end

    it 'is rendered as x when on the right side' do

      parser = Class.new(Neg::Parser) do
        word  == car | bus
        car   == `car`
        bus   == `bus`
      end

      parser.to_s.strip.should == %q{
:
  bus == `bus`
  car == `car`
  word == (car | bus)
  root: word
      }.strip
    end

    it 'flips burgers' do

      parser = Class.new(Neg::Parser) do
        sentence == (word + ` `) * 1
        word  == _("a-z") * 1
      end

      pp parser.parse("ab cd ")
    end
  end

  context '...["name"]' do

    let(:parser) {
      Class.new(Neg::Parser) do
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
          [ 0, 1, 1 ],
          true,
          nil,
          [ [ 'vehicle', [ 0, 1, 1 ], true, nil, [
            [ nil, [ 0, 1, 1 ], true, 'car', [] ] ] ],
          [ nil, [ 3, 1, 4 ], true, '_', [] ],
          [ 'city', [ 4, 1, 5 ], true, nil, [
            [ nil, [ 4, 1, 5 ], true, 'cluj', [] ] ] ] ] ]
    end
  end
end

