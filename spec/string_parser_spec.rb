
require 'spec_helper'


describe Leg::Parser::StringParser do

  it 'parses an exact string' do

    parser = Leg::Parser::StringParser.new('xxx')

    parser.parse('xxx').should == true
  end

  context 'within Leg::Parser' do

    it 'parses an exact string' do

      class Parser < Leg::Parser
        def root
          `x`
        end
      end

      Parser.new.parse('x').should == true
    end
  end
end

