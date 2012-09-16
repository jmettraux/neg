
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

  describe '.parse' do

    let(:parser) {
      Class.new(Neg::Parser) do
        text == `x`
      end
    }

    it 'raises on unconsumed input' do

      lambda {
        parser.parse('xy')
      }.should raise_error(
        Neg::UnconsumedInputError,
        'remaining: "y"')
    end

    it 'raises on unconsumed input (...)' do

      lambda {
        parser.parse('xyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy')
      }.should raise_error(
        Neg::UnconsumedInputError,
        'remaining: "yyyyyyy..."')
    end
  end
end

