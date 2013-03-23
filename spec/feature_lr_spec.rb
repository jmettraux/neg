
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
  root: exp
      }.strip
    end

    it 'parses additions' do

      pp dparse('1+1+1')
    end

    # TODO: class TranslatedLrParser
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

      pp nparse('2+2+2')
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

