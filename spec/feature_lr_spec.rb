
require 'spec_helper'


describe 'lr feature' do

  context 'direct lr' do

    class DirectLrParser < Neg::Parser

      exp == exp + `+` + num | num
      num == _('0-9')
    end

    def dparse(s, opts={})

      DirectLrParser.parse(s, opts)
    end

    it 'parses additions' do

      #dparse('10+12').should ==
      #  [ :exp, [ 0, 1, 1 ], true, nil, [
      #    [ nil, [ 0, 1, 1 ], true, nil, [
      #      [ :exp, [ 0, 1, 1 ], true, nil, [
      #        [ :num, [ 0, 1, 1 ], true, '10', [] ] ] ],
      #        [ nil, [ 2, 1, 3 ], true, '+', [] ],
      #        [ :num, [ 3, 1, 4 ], true, '12', [] ] ] ] ] ]
      pp dparse('1+2+3')
    end

    # TODO: class TranslatedLrParser
  end

  context 'nested lr' do

    class NestedLrParser < Neg::Parser

      x == exp
      exp == x + `+` + num | num
      num == _('0-9')
    end

    def nparse(s, opts={})

      NestedLrParser.parse(s, opts)
    end

    it 'parses additions' do

      pp nparse('4+5+6')
    end
  end

  context 'indirect lr' do

    class IndirectLrParser < Neg::Parser

      exp == x + `+` + num | num
      x == exp
      num == _('0-9')
    end

    def iparse(s, opts={})

      IndirectLrParser.parse(s, opts)
    end

    it 'parses additions' do

      pp iparse('7+8+9')
    end
  end
end

