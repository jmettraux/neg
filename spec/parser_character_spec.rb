
require 'spec_helper'


describe Neg::Parser::CharacterParser do

  context '_ (any)' do

    let(:parser) {
      Class.new(Neg::Parser) do
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

  context "_('0-9-') (ranges)" do

    let(:parser) {
      Class.new(Neg::Parser) do
        text == `tel:` + _('0-9-') * 1
      end
    }

    it 'parses "tel:0-99"' do

      parser.parse('tel:0-99').should ==
        [ :text,
          true,
          [ 0, 1, 1 ],
          [ [ nil, true, [ 0, 1, 1 ], "tel:" ],
            [ nil,
              true,
              [ 4, 1, 5 ],
              [ [ nil, true, [ 4, 1, 5 ], "0" ],
                [ nil, true, [ 5, 1, 6 ], "-" ],
                [ nil, true, [ 6, 1, 7 ], "9" ],
                [ nil, true, [ 7, 1, 8 ], "9" ] ] ] ] ]
    end

    it 'fails gracefully' do

      parser.parse('tel:a-bc').should ==
        [ :text,
          false,
          [ 0, 1, 1 ],
          [ [ nil, true, [ 0, 1, 1 ], "tel:" ],
            [ nil,
              false,
              [ 4, 1, 5 ],
              [ [ nil, false, [ 4, 1, 5 ], "\"a\" doesn't match \"0-9-\"" ] ] ] ] ]
    end
  end
end

