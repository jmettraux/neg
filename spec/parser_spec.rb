
require 'spec_helper'


describe Leg::Parser do

  describe 'composition' do

    let(:parser) {
      Class.new(Leg::Parser) do
        def text
          `x` + `y`
        end
      end
    }

    it 'parses' do

      parser.parse('xy').should ==
        [ :text, true, [ 0, 1, 1 ], [
          [ nil, true, [ 0, 1, 1 ], 'x' ],
          [ nil, true, [ 1, 1, 2 ], 'y' ] ] ]
    end

    it 'fails gracefully' do

      parser.parse('xx').should ==
        [ :text, false, [ 0, 1, 1 ], [
          [ nil, true, [ 0, 1, 1 ], 'x' ],
          [ nil, false, [ 1, 1, 2 ], 'expected "y", got "x"' ] ] ]
    end
  end
end

