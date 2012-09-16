
require 'spec_helper'


describe Neg::Parser::RepetitionParser do

  context '`x` * -1 (maybe)' do

    let(:parser) {
      Class.new(Neg::Parser) do
        text == `x` * -1
      end
    }

    it 'parses the empty string' do

      parser.parse('').should ==
        [ :text, true, [ 0, 1, 1 ], [] ]
    end

    it 'fails gracefully' do

      lambda {
        parser.parse('xx')
      }.should raise_error(
        Neg::UnconsumedInputError,
        'remaining: "x"')
    end

    it 'is rendered correctly via #to_s' do

      parser.to_s.strip.should == %q{
:
  text == `x` * -1
  root: text
      }.strip
    end
  end

  context '`x` * 0 (0 or more)' do

    let(:parser) {
      Class.new(Neg::Parser) do
        text == `x` * 0
      end
    }

    it 'parses the empty string' do

      parser.parse('').should ==
        [ :text, true, [ 0, 1, 1 ], [] ]
    end

    it 'parses' do

      parser.parse('xxx').should ==
        [ :text, true, [ 0, 1, 1 ], [
          [ nil, true, [ 0, 1, 1 ], 'x' ],
          [ nil, true, [ 1, 1, 2 ], 'x' ],
          [ nil, true, [ 2, 1, 3 ], 'x' ] ] ]
    end

    it 'fails gracefully' do

      lambda {
        parser.parse('a')
      }.should raise_error(
        Neg::UnconsumedInputError,
        'remaining: "a"')
    end
  end

  context '`x` * 2 (at least 2)' do

    let(:parser) {
      Class.new(Neg::Parser) do
        text == `x` * 2
      end
    }

    it 'parses' do

      parser.parse('xxx').should ==
        [ :text, true, [ 0, 1, 1 ], [
          [ nil, true, [ 0, 1, 1 ], 'x' ],
          [ nil, true, [ 1, 1, 2 ], 'x' ],
          [ nil, true, [ 2, 1, 3 ], 'x' ] ] ]
    end

    it 'fails gracefully' do

      parser.parse('x').should ==
        [ :text, false, [ 0, 1, 1 ], [
          [ nil, true, [ 0, 1, 1 ], 'x' ],
          [ nil, false, [ 1, 1, 2 ], 'expected "x", got ""' ] ] ]
    end
  end

  context '`x` * [ 3, 3 ] (at least 3, max 3)' do

    let(:parser) {
      Class.new(Neg::Parser) do
        text == `x` * [ 3, 3 ]
      end
    }

    it 'parses' do

      parser.parse('xxx').should ==
        [ :text, true, [ 0, 1, 1 ], [
          [ nil, true, [ 0, 1, 1 ], 'x' ],
          [ nil, true, [ 1, 1, 2 ], 'x' ],
          [ nil, true, [ 2, 1, 3 ], 'x' ] ] ]
    end

    it 'fails gracefully' do

      parser.parse('xx').should ==
        [ :text, false, [ 0, 1, 1 ], [
          [ nil, true, [ 0, 1, 1 ], 'x' ],
          [ nil, true, [ 1, 1, 2 ], 'x' ],
          [ nil, false, [ 2, 1, 3 ], 'expected "x", got ""' ] ] ]
    end

    it 'fails gracefully (unconsumed input)' do

      lambda {
        parser.parse('xxxx')
      }.should raise_error(Neg::UnconsumedInputError, 'remaining: "x"')
    end

    it 'is rendered correctly via #to_s' do

      parser.to_s.strip.should == %q{
:
  text == `x` * [3, 3]
  root: text
      }.strip
    end
  end
end

