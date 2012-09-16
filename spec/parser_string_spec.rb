
require 'spec_helper'


describe Neg::Parser::StringParser do

  context 'standalone' do

    it 'parses' do

      parser = Neg::Parser::StringParser.new('xxx')

      parser.parse('xxx').should ==
        [ nil, true, [ 0, 1, 1 ], 'xxx' ]
    end

    it 'fails gracefully' do

      parser = Neg::Parser::StringParser.new('xxx')

      parser.parse('yyy').should ==
        [ nil, false, [ 0, 1, 1 ], 'expected "xxx", got "yyy"' ]
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
        [ :root, true, [ 0, 1, 1 ], 'x' ]
    end
  end
end

