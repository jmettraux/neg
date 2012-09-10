
require 'spec_helper'


describe Leg::Parser::Input do

  before(:each) do
    @input = Leg::Parser::Input.new("the quick blue fox\n jumped the shark\n")
    class << @input
      attr_accessor :offset, :line, :column
    end
  end

  it 'starts at zero' do

    @input.offset.should == 0
    @input.line.should == 1
    @input.column.should == 1
  end

  it "reads but doesn't move" do

    @input.read(5).should == 'the q'

    @input.offset.should == 0
    @input.line.should == 1
    @input.column.should == 1
  end

  it 'skips (same line)' do

    @input.skip(5)

    @input.read(4).should == 'uick'
    @input.offset.should == 5
    @input.line.should == 1
    @input.column.should == 6
  end

  it 'skips (new line)' do

    @input.skip(21)

    @input.read(4).should == 'umpe'
    @input.offset.should == 21
    @input.line.should == 2
    @input.column.should == 3
  end

  it 'rewinds' do

    @input.skip(21)
    @input.rewind

    @input.read(5).should == 'the q'
    @input.offset.should == 0
    @input.line.should == 1
    @input.column.should == 1
  end

  it 'rewinds with an offset' do

    @input.skip(21)
    @input.rewind(22)
    @input.read(4).should == 'mped'
    @input.offset.should == 22
    @input.line.should == 2
    @input.column.should == 4
  end
end

