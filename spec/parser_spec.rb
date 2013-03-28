
require 'spec_helper'


describe 'Neg::Parser' do

  describe 'using parentheses' do

    it 'influences precedence' do

      parser = Class.new(Neg::Parser) do
        t0 == `x` + `y` | `z`
        t1 == (`x` | `y`) + `z`
      end

      parser.t0.to_s.should == 't0 == ((`x` + `y`) | `z`)'
      parser.t1.to_s.should == 't1 == ((`x` | `y`) + `z`)'
    end
  end

#  describe 'the blankslate' do
#
#    it 'lets through node names like "send"' do
#
#      parser =
#        Class.new(Neg::Parser) do
#          send == `x`
#        end
#
#      parser.parse("x").should == [ :send, [ 0, 1, 1 ], true, 'x', [] ]
#    end
#  end
  #
  # not worth the pain for now

#  describe '.parse' do
#
#    let(:parser) {
#      Class.new(Neg::Parser) do
#        text == `x`
#      end
#    }
#
#    it 'raises on unconsumed input' do
#
#      lambda {
#        parser.parse('xy')
#      }.should raise_error(
#        Neg::UnconsumedInputError,
#        'remaining: "y"')
#    end
#
#    it 'raises on unconsumed input (...)' do
#
#      lambda {
#        parser.parse('xyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy')
#      }.should raise_error(
#        Neg::UnconsumedInputError,
#        'remaining: "yyyyyyy..."')
#    end
#  end
  #
  # UnconsumedInputError is gone.

  context 'unconsumed input' do

    let(:parser) {
      Class.new(Neg::Parser) do
        text == `x` * -1
      end
    }

    it 'fails gracefully' do

      parser.parse('xx').should ==
        [ :text,
          [ 0, 1, 1 ],
           false,
            'x',
             [ [ nil, [0, 1, 1], true, 'x', [] ],
               [ nil, [1, 1, 2], false, 'did not expect "x" (min 0 max 1)', [] ] ] ]
    end
  end

  context 'recursion' do

    let(:parser0) {
      Class.new(Neg::Parser) do
        text == `x` * -1
      end
    }
    let(:parser1) {
      Class.new(Neg::Parser) do
        exp == exp + `+` + `1` | `1`
      end
    }

    describe 'Parser#recursive?' do

      it 'returns false when the grammar is not recursive' do

        parser0.recursive?.class.should == FalseClass
      end

      it 'returns true when the grammar is not recursive' do

        parser1.recursive?.class.should == TrueClass
      end
    end
  end
end

