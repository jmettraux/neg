
require 'spec_helper'


describe Leg::Parser::CharacterParser do

  context '_ (any)' do

    let(:parser) {
      Class.new(Leg::Parser) do
        text == `x` + _
      end
    }

    it 'parses "xy"' do

      parser.parse('xy').should ==
        [ :text,
          true,
          [ 0, 1, 1 ],
          [ [ nil, true, [ 0, 1, 1 ], "x" ],
            [ nil, true, [ 1, 1, 2 ], "y" ] ] ]
    end

    it 'fails gracefully' do

      parser.parse('x').should ==
        [ :text,
          false,
          [ 0, 1, 1],
          [ [ nil, true, [ 0, 1, 1 ], "x" ],
            [ nil, false, [ 1, 1, 2 ], "\"\" doesn't match nil" ] ] ]
    end

    it 'is rendered correctly via #to_s' do

      parser.to_s.strip.should == %q{
:
  text == (`x` + _)
  root: text
      }.strip
    end
  end
end

