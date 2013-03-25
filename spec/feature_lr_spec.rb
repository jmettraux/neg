
require 'spec_helper'

# TODO: add spec with right recursion.


describe 'lr feature' do

  context 'direct lr' do

    class DirectLrParser < Neg::Parser

      exp == exp + `+` + `1` | `1`
    end

    def dparse(s, opts={})

      DirectLrParser.parse(s, opts)
    end

    it 'renders via #to_s' do

      DirectLrParser.to_s.strip.should == %{
DirectLrParser:
  exp == ((exp + `+` + `1`) | `1`)
  root: exp
      }.strip
    end

    it 'parses additions' do

      dparse('1+1+1').should ==
        [:exp,
         [0, 1, 1],
         true,
         nil,
         [[:exp,
           [0, 1, 1],
           true,
           nil,
           [[:exp, [0, 1, 1], true, "1", []],
            [nil, [1, 1, 2], true, "+", []],
            [nil, [2, 1, 3], true, "1", []]]],
          [nil, [3, 1, 4], true, "+", []],
          [nil, [4, 1, 5], true, "1", []]]]
    end

    class TranslatedDirectLrParser < Neg::Parser

      parser do
        exp == exp + `+` + `1` | `1`
      end

      translator do
        on(:exp) { |n|
          puts '+' * 80
          p n.class
          p n
          p n.result
          puts '-' * 80
          if n.result
            n.result
          else
            n.parse_tree.last.collect { |c| c[3] }
          end
        }
      end
    end

    it 'parses additions' do

      pp TranslatedDirectLrParser.parse('1+1+1')
    end
  end

  context 'direct lr (2)' do

    class NestedLrParser < Neg::Parser

      x == exp
      exp == x + `+` + `2` | `2`
    end

    def nparse(s, opts={})

      NestedLrParser.parse(s, opts)
    end

    it 'parses additions' do

      nparse('2+2+2').should ==
        [:x,
         [0, 1, 1],
         true,
         nil,
         [[:x,
           [0, 1, 1],
           true,
           nil,
           [[:x, [0, 1, 1], true, "2", []],
            [nil, [1, 1, 2], true, "+", []],
            [nil, [2, 1, 3], true, "2", []]]],
          [nil, [3, 1, 4], true, "+", []],
          [nil, [4, 1, 5], true, "2", []]]]
    end
  end

  context 'indirect lr' do

    class IndirectLrParser < Neg::Parser

      exp == x + `+` + `3` | `3`
      x == exp
    end

    def iparse(s, opts={})

      IndirectLrParser.parse(s, opts)
    end

    it 'renders via #to_s' do

      IndirectLrParser.to_s.strip.should == %{
IndirectLrParser:
  exp == ((x + `+` + `3`) | `3`)
  x == exp
  root: exp
      }.strip
    end

    it 'parses additions' do

      pp iparse('3+3+3')
    end
  end
end

