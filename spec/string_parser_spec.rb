
require 'spec_helper'


describe '`x`' do

  it 'parses an exact string' do

    class Parser < Leg::Parser
      def root
        `x`
      end
    end

    Parser.new.parse('x').should == true
  end
end

