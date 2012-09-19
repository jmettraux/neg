
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
          [ 0, 1, 1 ],
          true,
          [ [ nil, [ 0, 1, 1 ], true, "x" ],
            [ nil, [ 1, 1, 2 ], true, "y" ] ] ]
    end

    it 'fails gracefully' do

      parser.parse('x').should ==
        [ :text,
          [ 0, 1, 1],
          false,
          [ [ nil, [ 0, 1, 1 ], true, "x" ],
            [ nil, [ 1, 1, 2 ], false, "\"\" doesn't match nil" ] ] ]
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
          [ 0, 1, 1 ],
          true,
          [ [ nil, [ 0, 1, 1 ], true, "tel:" ],
            [ nil,
              [ 4, 1, 5 ],
              true,
              [ [ nil, [ 4, 1, 5 ], true, "0" ],
                [ nil, [ 5, 1, 6 ], true, "-" ],
                [ nil, [ 6, 1, 7 ], true, "9" ],
                [ nil, [ 7, 1, 8 ], true, "9" ] ] ] ] ]
    end

    it 'fails gracefully' do

      parser.parse('tel:a-bc').should ==
        [ :text,
          [ 0, 1, 1 ],
          false,
          [ [ nil, [ 0, 1, 1 ], true, "tel:" ],
            [ nil,
              [ 4, 1, 5 ],
              false,
              [ [ nil, [ 4, 1, 5 ], false, "\"a\" doesn't match \"0-9-\"" ] ] ] ] ]
    end

    it 'is rendered correctly via #to_s' do

      parser.to_s.strip.should == %q{
:
  text == (`tel:` + _("0-9-") * 1)
  root: text
      }.strip
    end
  end
end

