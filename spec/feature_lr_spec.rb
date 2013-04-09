
require 'spec_helper'


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
      }.strip
    end

    it 'parses additions' do

      dparse('1+1+1').should ==
        [:exp,
         0,
         true,
         nil,
         [[:exp,
           0,
           true,
           nil,
           [[:exp, 0, true, "1", []],
            [nil, 1, true, "+", []],
            [nil, 2, true, "1", []]]],
          [nil, 3, true, "+", []],
          [nil, 4, true, "1", []]]]
    end

    class TranslatedDirectLrParser < Neg::Parser

      parser do
        exp == exp + `+` + `1` | `1`
      end

      translator do
        on(:exp) { |n|
          #puts '+' * 80
          #p n.class
          #p n
          #p n.result
          #p n.flattened_results
          #p n.results
          #pp n.parse_tree.last
          #puts '-' * 80
          if n.result
            n.result
          else
            results = n.results.dup
            n.parse_tree.last.collect { |c|
              c[0].is_a?(Symbol) ? results.shift : c[3]
            }
          end
          #
          # TODO: package that translating trick into a Translator::Node method
        }
      end
    end

    it 'parses and translates additions' do

      TranslatedDirectLrParser.parse('1+1+1').should ==
        [ [ '1', '+', '1' ], '+', '1' ]
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
         0,
         true,
         nil,
         [[:x,
           0,
           true,
           nil,
           [[:x, 0, true, "2", []],
            [nil, 1, true, "+", []],
            [nil, 2, true, "2", []]]],
          [nil, 3, true, "+", []],
          [nil, 4, true, "2", []]]]
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
      }.strip
    end

    pending 'parses additions' do

      pp iparse('3+3+3')
    end
  end

  context 'rr' do

    it 'behaves'
  end
end

