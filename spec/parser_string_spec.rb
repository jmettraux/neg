
require 'spec_helper'


describe Neg::Parser::StringParser do

  context 'standalone' do

    it 'parses' do

      parser = Neg::Parser::StringParser.new('xxx')

      parser.parse('xxx').should ==
        [ nil, [ 0, 1, 1 ], true, 'xxx', [] ]
    end

    it 'fails gracefully' do

      parser = Neg::Parser::StringParser.new('xxx')

      parser.parse('yyy').should ==
        [ nil, [ 0, 1, 1 ], false, 'expected "xxx", got "yyy"', [] ]
    end
  end

  context 'within Neg::Parser' do

    let(:parser) {
      Class.new(Neg::Parser) do
        root == `x`
      end
    }

    it 'parses an exact string' do

      parser.parse('x').should ==
        [ :root, [ 0, 1, 1 ], true, 'x', [] ]
    end
  end
end

