
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
        [ :text, [ 0, 1, 1 ], true, '', [] ]
    end

    #it 'fails gracefully' do
    #  lambda {
    #    parser.parse('xx')
    #  }.should raise_error(
    #    Neg::UnconsumedInputError,
    #    'remaining: "x"')
    #end
      #
      # UnconsumedInputError is gone.

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
        [ :text, [ 0, 1, 1 ], true, '', [] ]
    end

    it 'parses' do

      parser.parse('xxx').should ==
        [ :text, [ 0, 1, 1 ], true, 'xxx', [] ]
    end

    #it 'fails gracefully' do
    #  lambda {
    #    parser.parse('a')
    #  }.should raise_error(
    #    Neg::UnconsumedInputError,
    #    'remaining: "a"')
    #end
      #
      # UnconsumedInputError is gone.
  end

  context '`x` * 2 (at least 2)' do

    let(:parser) {
      Class.new(Neg::Parser) do
        text == `x` * 2
      end
    }

    it 'parses' do

      parser.parse('xxx').should ==
        [ :text, [ 0, 1, 1 ], true, 'xxx', [] ]
    end

    it 'fails gracefully' do

      parser.parse('x').should ==
        [ :text, [ 0, 1, 1 ], false, nil, [
          [ nil, [ 0, 1, 1 ], true, 'x', [] ],
          [ nil, [ 1, 1, 2 ], false, 'expected "x", got ""', [] ] ] ]
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
        [ :text, [ 0, 1, 1 ], true, 'xxx', [] ]
    end

    it 'fails gracefully' do

      parser.parse('xx').should ==
        [ :text, [ 0, 1, 1 ], false, nil, [
          [ nil, [ 0, 1, 1 ], true, 'x', [] ],
          [ nil, [ 1, 1, 2 ], true, 'x', [] ],
          [ nil, [ 2, 1, 3 ], false, 'expected "x", got ""', [] ] ] ]
    end

    #it 'fails gracefully (unconsumed input)' do
    #  lambda {
    #    parser.parse('xxxx')
    #  }.should raise_error(Neg::UnconsumedInputError, 'remaining: "x"')
    #end
      #
      # UnconsumedInputError is gone.

    it 'is rendered correctly via #to_s' do

      parser.to_s.strip.should == %q{
:
  text == `x` * [3, 3]
  root: text
      }.strip
    end
  end
end

