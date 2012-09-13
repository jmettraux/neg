
require 'spec_helper'


describe Leg::Input do

  before(:each) do

    @input = Leg::Input.new("the quick blue fox\n jumped the shark\n")
  end

  it 'starts at zero' do

    @input.position.should == [ 0, 1, 1 ]
  end

  describe '#read' do

    it "reads and moves" do

      @input.read(5).should == 'the q'

      @input.position.should == [ 5, 1, 6 ]
    end

    it "reads and moves (same line)" do

      @input.read(9).should == 'the quick'

      @input.position.should == [ 9, 1, 10 ]
    end

    it "reads and moves (new line)" do

      @input.read(21).should == "the quick blue fox\n j"

      @input.position.should == [ 21, 2, 2 ]
    end
  end

  describe '#rewind' do

    it 'rewinds' do

      @input.read(21)
      @input.rewind

      @input.position.should == [ 0, 1, 1 ]
    end

    it 'rewinds with a [ off, line, col ]' do

      @input.read(21)
      @input.rewind([ 5, 1, 6 ])

      @input.read(4).should == 'uick'
    end
  end

  describe '#eoi?' do

    it 'returns false if the end of input has not yet been reached' do

      @input.eoi?.should == false
    end

    it 'returns true if the end of input has been reached' do

      @input.read(37)

      @input.eoi?.should == true
    end
  end
end

