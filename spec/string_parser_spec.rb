
require 'spec_helper'


describe Leg::Parser::StringParser do

  context 'standalone' do

    it 'parses' do

      parser = Leg::Parser::StringParser.new('xxx')

      parser.parse('xxx').should ==
        [ 'xxx', [ 0, 1, 1 ] ]
    end

    it 'fails gracefully' do

      parser = Leg::Parser::StringParser.new('xxx')

      parser.parse('yyy').should ==
        'expected "xxx", got "yyy" at line 1, column 1'
    end
  end

  context 'within Leg::Parser' do

    it 'parses an exact string' do

      class Parser < Leg::Parser
        def root
          `x`
        end
      end

      Parser.new.parse('x').should == [ :root, 'x', [ 0, 1, 1 ] ]
    end
  end
end

