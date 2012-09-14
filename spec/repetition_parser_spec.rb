
require 'spec_helper'


describe Leg::Parser::RepetitionParser do

  context '`x` ^ 2 (at least 2)' do

    let(:parser) {
      Class.new(Leg::Parser) do
        text == `x` ^ 2
      end
    }

    it 'parses' do

      parser.parse('xxx').should ==
        [ :text, true, [ 0, 1, 1 ], [
          [ nil, true, [ 0, 1, 1 ], 'x' ],
          [ nil, true, [ 1, 1, 2 ], 'x' ],
          [ nil, true, [ 2, 1, 3 ], 'x' ] ] ]
    end

    it 'fails gracefully' do

      parser.parse('x').should ==
        [ :text, false, [ 0, 1, 1 ], [
          [ nil, true, [ 0, 1, 1 ], 'x' ],
          [ nil, false, [ 1, 1, 2 ], 'expected "x", got ""' ] ] ]
    end
  end

  context '`x` ^ [ 3, 3 ] (at least 3, max 3)' do

    let(:parser) {
      Class.new(Leg::Parser) do
        text == `x` ^ [ 3, 3 ]
      end
    }

    it 'parses' do

      parser.parse('xxx').should ==
        [ :text, true, [ 0, 1, 1 ], [
          [ nil, true, [ 0, 1, 1 ], 'x' ],
          [ nil, true, [ 1, 1, 2 ], 'x' ],
          [ nil, true, [ 2, 1, 3 ], 'x' ] ] ]
    end

    it 'fails gracefully' do

      parser.parse('xx').should ==
        [ :text, false, [ 0, 1, 1 ], [
          [ nil, true, [ 0, 1, 1 ], 'x' ],
          [ nil, true, [ 1, 1, 2 ], 'x' ],
          [ nil, false, [ 2, 1, 3 ], 'expected "x", got ""' ] ] ]
    end

    it 'fails gracefully (unconsumed input)' do

      lambda {
        parser.parse('xxxx')
      }.should raise_error(Leg::UnconsumedInputError, 'remaining: "x"')
    end
  end
end

