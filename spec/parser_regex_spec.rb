
require 'spec_helper'


describe Neg::Parser::RegexParser do

  context '_ (any)' do

    let(:parser) {
      Class.new(Neg::Parser) do
        text == `x` + _
      end
    }

    it 'parses "xy"' do

      parser.parse('xy').should ==
        [ :text, 0, true, 'xy', [] ]
    end

    it 'fails gracefully' do

      parser.parse('x').should ==
        [ :text,
          0,
          false,
          nil,
          [ [ nil, 0, true, "x", [] ],
            [ nil, 1, false, "\"\" doesn't match nil", [] ] ] ]
    end

    it 'is rendered correctly via #to_s' do

      parser.to_s.strip.should == %q{
:
  text == (`x` + _)
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
        [ :text, 0, true, 'tel:0-99', [] ]
    end

    it 'fails gracefully' do

      parser.parse('tel:a-bc').should ==
        [ :text,
          0,
          false,
          nil,
          [ [ nil, 0, true, "tel:", [] ],
            [ nil,
              4,
              false,
              nil,
              [ [ nil, 4, false, "\"a\" doesn't match \"0-9-\"", [] ] ] ] ] ]
    end

    it 'is rendered correctly via #to_s' do

      parser.to_s.strip.should == %q{
:
  text == (`tel:` + _("0-9-") * 1)
      }.strip
    end
  end

  context "_(/[0-9-]+/) (direct regex)" do

    let(:parser) {
      Class.new(Neg::Parser) do
        text == _(/^tel:[\d-]+/)
      end
    }

    it 'parses "tel:0-99"' do

      parser.parse('tel:0-99').should ==
        [ :text, 0, true, 'tel:0-99', [] ]
    end

    it 'fails gracefully' do

      parser.parse('tel:a-bc').should ==
        [ :text,
          0,
          false,
          '"tel:a-bc" doesn\'t match /^tel:[\\d-]+/',
          [] ]
    end

    it 'is rendered correctly via #to_s' do

      parser.to_s.strip.should == %q{
:
  text == _(/^tel:[\d-]+/)
      }.strip
    end
  end
end

